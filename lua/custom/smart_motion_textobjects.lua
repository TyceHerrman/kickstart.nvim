local M = {}

local MAX_LINES = 500

local function char_at(text, offset) return text:sub(offset + 1, offset + 1) end

local function is_space(ch) return ch ~= '' and ch:match '%s' ~= nil end

local function is_name_char(ch) return ch ~= '' and ch:match '[%w_%.]' ~= nil end

local function is_escaped(text, offset)
  local count = 0
  local i = offset - 1
  while i >= 0 and char_at(text, i) == '\\' do
    count = count + 1
    i = i - 1
  end
  return count % 2 == 1
end

local function trim_range(text, start_abs, end_abs)
  while start_abs < end_abs and is_space(char_at(text, start_abs)) do
    start_abs = start_abs + 1
  end
  while end_abs > start_abs and is_space(char_at(text, end_abs - 1)) do
    end_abs = end_abs - 1
  end
  return start_abs, end_abs
end

local function snapshot(ctx, max_lines)
  local bufnr = ctx.bufnr
  local total = vim.api.nvim_buf_line_count(bufnr)
  local cursor_line = ctx.cursor_line or (vim.api.nvim_win_get_cursor(ctx.winid or 0)[1] - 1)
  local cursor_col = ctx.cursor_col or vim.api.nvim_win_get_cursor(ctx.winid or 0)[2]
  local start_line = math.max(0, cursor_line - (max_lines or MAX_LINES))
  local end_line = math.min(total - 1, cursor_line + (max_lines or MAX_LINES))
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
  local text = table.concat(lines, '\n')
  local starts = { 0 }
  local offset = 0

  for i, line in ipairs(lines) do
    if i < #lines then
      offset = offset + #line + 1
      starts[i + 1] = offset
    end
  end

  return {
    bufnr = bufnr,
    start_line = start_line,
    lines = lines,
    text = text,
    starts = starts,
    cursor_abs = (starts[cursor_line - start_line + 1] or 0) + cursor_col,
  }
end

local function abs_to_pos(snap, abs)
  local lo, hi = 1, #snap.starts
  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    if snap.starts[mid] <= abs then
      lo = mid + 1
    else
      hi = mid - 1
    end
  end

  local idx = math.max(1, hi)
  return { row = snap.start_line + idx - 1, col = abs - snap.starts[idx] }
end

local function make_target(snap, start_abs, end_abs, kind)
  if not start_abs or not end_abs or end_abs <= start_abs then return nil end
  local start_pos = abs_to_pos(snap, start_abs)
  local end_pos = abs_to_pos(snap, end_abs)

  return {
    row = start_pos.row,
    col = start_pos.col,
    line_number = start_pos.row,
    start_pos = start_pos,
    end_pos = end_pos,
    text = snap.text:sub(start_abs + 1, end_abs),
    type = kind,
    metadata = { textobject = kind },
  }
end

local function range_distance(snap, range)
  if range.start_abs <= snap.cursor_abs and snap.cursor_abs < range.end_abs then return 0 end
  if range.start_abs > snap.cursor_abs then return range.start_abs - snap.cursor_abs end
  return snap.cursor_abs - range.end_abs
end

local function sort_ranges(snap, ranges)
  table.sort(ranges, function(a, b)
    local da = range_distance(snap, a)
    local db = range_distance(snap, b)
    if da ~= db then return da < db end
    return a.start_abs < b.start_abs
  end)
  return ranges
end

local function filter_direction(snap, ranges, direction)
  if direction ~= 'next' and direction ~= 'prev' then return ranges end

  local filtered = {}
  for _, range in ipairs(ranges) do
    if direction == 'next' and range.start_abs > snap.cursor_abs then
      table.insert(filtered, range)
    elseif direction == 'prev' and range.end_abs <= snap.cursor_abs then
      table.insert(filtered, range)
    end
  end

  table.sort(filtered, function(a, b)
    if direction == 'next' then return a.start_abs < b.start_abs end
    return a.end_abs > b.end_abs
  end)

  if filtered[1] then return { filtered[1] } end
  return filtered
end

local function pair_ranges(snap, left, right)
  local text = snap.text
  local ranges = {}

  if left == right then
    local open_abs = nil
    local i = 0
    while i < #text do
      if char_at(text, i) == left and not is_escaped(text, i) then
        if open_abs then
          table.insert(ranges, { start_abs = open_abs, end_abs = i + 1, left_abs = open_abs, right_abs = i })
          open_abs = nil
        else
          open_abs = i
        end
      end
      i = i + 1
    end
    return ranges
  end

  local stack = {}
  for i = 0, #text - 1 do
    local ch = char_at(text, i)
    if ch == left then
      table.insert(stack, i)
    elseif ch == right and #stack > 0 then
      local start_abs = table.remove(stack)
      table.insert(ranges, { start_abs = start_abs, end_abs = i + 1, left_abs = start_abs, right_abs = i })
    end
  end

  return ranges
end

local PAIRS = {
  ['('] = { '(', ')', trim = true },
  [')'] = { '(', ')', trim = false },
  ['['] = { '[', ']', trim = true },
  [']'] = { '[', ']', trim = false },
  ['{'] = { '{', '}', trim = true },
  ['}'] = { '{', '}', trim = false },
  ['<'] = { '<', '>', trim = true },
  ['>'] = { '<', '>', trim = false },
  ['"'] = { '"', '"', trim = false },
  ["'"] = { "'", "'", trim = false },
  ['`'] = { '`', '`', trim = false },
}

local function collect_pairs(snap, ids, side)
  local seen = {}
  local ranges = {}

  for _, id in ipairs(ids) do
    local spec = PAIRS[id]
    if spec then
      for _, range in ipairs(pair_ranges(snap, spec[1], spec[2])) do
        local start_abs, end_abs = range.start_abs, range.end_abs
        if side == 'i' then
          start_abs, end_abs = range.left_abs + 1, range.right_abs
          if spec.trim then
            start_abs, end_abs = trim_range(snap.text, start_abs, end_abs)
          end
        end

        local key = start_abs .. ':' .. end_abs
        if not seen[key] then
          seen[key] = true
          table.insert(ranges, { start_abs = start_abs, end_abs = end_abs, kind = id })
        end
      end
    end
  end

  return ranges
end

local function split_arguments(snap, open_abs, close_abs)
  local text = snap.text
  local args = {}
  local seg_start = open_abs + 1
  local quote = nil
  local depth = 0
  local separators = {}
  local i = seg_start

  while i < close_abs do
    local ch = char_at(text, i)

    if quote then
      if ch == quote and not is_escaped(text, i) then quote = nil end
    elseif ch == '"' or ch == "'" or ch == '`' then
      quote = ch
    elseif ch == '(' or ch == '[' or ch == '{' then
      depth = depth + 1
    elseif ch == ')' or ch == ']' or ch == '}' then
      depth = math.max(0, depth - 1)
    elseif ch == ',' and depth == 0 then
      table.insert(args, { start_abs = seg_start, end_abs = i, comma_abs = i })
      table.insert(separators, i)
      seg_start = i + 1
      while seg_start < close_abs and is_space(char_at(text, seg_start)) do
        seg_start = seg_start + 1
      end
    end

    i = i + 1
  end

  table.insert(args, { start_abs = seg_start, end_abs = close_abs })
  return args, separators
end

local function collect_arguments(snap, side)
  local ranges = {}
  local containers = {}

  for _, spec in ipairs { { '(', ')' }, { '[', ']' }, { '{', '}' } } do
    for _, range in ipairs(pair_ranges(snap, spec[1], spec[2])) do
      table.insert(containers, range)
    end
  end

  for _, container in ipairs(containers) do
    local args = split_arguments(snap, container.left_abs, container.right_abs)
    for idx, arg in ipairs(args) do
      local inside_start, inside_end = trim_range(snap.text, arg.start_abs, arg.end_abs)
      if inside_end > inside_start then
        local start_abs, end_abs = inside_start, inside_end

        if side == 'a' then
          if arg.comma_abs then
            start_abs = arg.start_abs
            end_abs = arg.comma_abs + 1
            while end_abs < container.right_abs and is_space(char_at(snap.text, end_abs)) do
              end_abs = end_abs + 1
            end
          elseif idx > 1 then
            local comma_abs = arg.start_abs - 1
            while comma_abs > container.left_abs and is_space(char_at(snap.text, comma_abs)) do
              comma_abs = comma_abs - 1
            end
            start_abs = comma_abs
            end_abs = arg.end_abs
          else
            start_abs = arg.start_abs
            end_abs = arg.end_abs
          end
        end

        table.insert(ranges, { start_abs = start_abs, end_abs = end_abs, kind = 'argument' })
      end
    end
  end

  return ranges
end

local function collect_function_calls(snap, side)
  local ranges = {}

  for _, range in ipairs(pair_ranges(snap, '(', ')')) do
    local name_end = range.left_abs
    local name_start = name_end - 1
    while name_start >= 0 and is_name_char(char_at(snap.text, name_start)) do
      name_start = name_start - 1
    end
    name_start = name_start + 1

    if name_start < name_end then
      if side == 'a' then
        table.insert(ranges, { start_abs = name_start, end_abs = range.end_abs, kind = 'function-call' })
      else
        table.insert(ranges, { start_abs = range.left_abs + 1, end_abs = range.right_abs, kind = 'function-call' })
      end
    end
  end

  return ranges
end

local function collect_tags(snap, side)
  local ranges = {}
  local stacks = {}
  local text = snap.text
  local init = 1

  while true do
    local start_idx, end_idx, closing, name, attrs = text:find('<%s*(/?)([%w:_%-%.]+)([^<>]*)>', init)
    if not start_idx then break end

    local self_closing = attrs and attrs:match '/%s*$'
    if closing == '/' then
      local stack = stacks[name]
      local open = stack and table.remove(stack)
      if open then
        if side == 'a' then
          table.insert(ranges, { start_abs = open.start_abs, end_abs = end_idx, kind = 'tag' })
        else
          table.insert(ranges, { start_abs = open.end_abs, end_abs = start_idx - 1, kind = 'tag' })
        end
      end
    elseif not self_closing then
      stacks[name] = stacks[name] or {}
      table.insert(stacks[name], { start_abs = start_idx - 1, end_abs = end_idx })
    end

    init = end_idx + 1
  end

  return ranges
end

local function read_object_id(prompt)
  local ok, value = pcall(vim.fn.getcharstr)
  if not ok then return nil end
  if value == '\027' or value == '' then return nil end
  if value == '<lt>' then return '<' end
  return value
end

local function prompt_pair_ids()
  local value = vim.fn.input 'Textobject delimiters: '
  if value == nil or value == '' then return nil end
  if #value == 1 then return { value } end

  PAIRS['?'] = { value:sub(1, 1), value:sub(-1), trim = false }
  return { '?' }
end

local function collect_for_id(snap, id, side)
  if not id then return {} end
  if id == '<lt>' then id = '<' end

  if id == '?' then
    local ids = prompt_pair_ids()
    if not ids then return {} end
    return collect_pairs(snap, ids, side)
  end

  if id == 'q' then return collect_pairs(snap, { '"', "'", '`' }, side) end
  if id == 'b' then return collect_pairs(snap, { ')', ']', '}' }, side) end
  if id == 'a' then return collect_arguments(snap, side) end
  if id == 'f' then return collect_function_calls(snap, side) end
  if id == 't' then return collect_tags(snap, side) end
  if PAIRS[id] then return collect_pairs(snap, { id }, side) end

  return {}
end

local collector = {
  run = function()
    return coroutine.create(function(ctx, _, motion_state)
      local side = motion_state.textobject_side or 'a'
      local id = motion_state.textobject_id
      if motion_state.read_textobject_id then id = read_object_id() end
      if not id then return end

      local snap = snapshot(ctx, motion_state.max_lines or MAX_LINES)
      local ranges = collect_for_id(snap, id, side)
      ranges = filter_direction(snap, sort_ranges(snap, ranges), motion_state.textobject_direction)

      for _, range in ipairs(ranges) do
        local target = make_target(snap, range.start_abs, range.end_abs, range.kind or id)
        if target then coroutine.yield(target) end
      end
    end)
  end,
  metadata = {
    label = 'Mini.ai Textobjects',
    description = 'SmartMotion collector for Mini.ai-compatible textobjects',
  },
}

local function textobject_motion(key, id, side, label, opts)
  opts = opts or {}
  return {
    trigger_key = key,
    collector = 'mini_ai_textobjects',
    extractor = 'pass_through',
    filter = 'filter_visible',
    visualizer = 'hint_start',
    action = 'textobject_select',
    map = true,
    modes = { 'x', 'o' },
    label = label,
    description = label,
    metadata = { label = label, description = label },
    is_textobject = true,
    textobject_id = id,
    textobject_side = side,
    textobject_direction = opts.direction,
    read_textobject_id = opts.read_textobject_id,
    max_lines = MAX_LINES,
  }
end

local function treesitter_motion(key, label, node_types, inner)
  return {
    trigger_key = key,
    collector = 'treesitter',
    extractor = 'pass_through',
    filter = 'filter_visible',
    visualizer = 'hint_start',
    action = 'textobject_select',
    map = true,
    modes = { 'x', 'o' },
    label = label,
    description = label,
    metadata = { label = label, description = label },
    ts_node_types = node_types,
    ts_inner_body = inner,
    is_textobject = true,
  }
end

local function mini_motions()
  local motions = {}
  local labels = {
    ['('] = 'Paren',
    [')'] = 'Paren',
    ['['] = 'Bracket',
    [']'] = 'Bracket',
    ['{'] = 'Brace',
    ['}'] = 'Brace',
    ['<'] = 'Angle',
    ['>'] = 'Angle',
    ['"'] = 'Double Quote',
    ["'"] = 'Single Quote',
    ['`'] = 'Backtick',
    q = 'Quote',
    b = 'Bracket Alias',
    a = 'Argument',
    f = 'Function Call',
    t = 'Tag',
    ['?'] = 'Prompted Object',
  }

  for id, label in pairs(labels) do
    motions['around_' .. id] = textobject_motion('a' .. id, id, 'a', 'Around ' .. label)
    motions['inside_' .. id] = textobject_motion('i' .. id, id, 'i', 'Inside ' .. label)
  end

  motions.around_next = textobject_motion('aN', nil, 'a', 'Around Next Textobject', {
    direction = 'next',
    read_textobject_id = true,
  })
  motions.inside_next = textobject_motion('iN', nil, 'i', 'Inside Next Textobject', {
    direction = 'next',
    read_textobject_id = true,
  })
  motions.around_last = textobject_motion('al', nil, 'a', 'Around Last Textobject', {
    direction = 'prev',
    read_textobject_id = true,
  })
  motions.inside_last = textobject_motion('il', nil, 'i', 'Inside Last Textobject', {
    direction = 'prev',
    read_textobject_id = true,
  })

  return motions
end

local function treesitter_compat_motions()
  local function_nodes = {
    'function_declaration',
    'function_definition',
    'arrow_function',
    'method_definition',
    'function_item',
    'method_declaration',
    'method',
  }
  local class_nodes = {
    'class_declaration',
    'class_definition',
    'struct_item',
    'struct_definition',
    'interface_declaration',
    'impl_item',
    'type_alias_declaration',
    'module',
  }
  local scope_nodes = {
    'if_statement',
    'if_expression',
    'else_clause',
    'elif_clause',
    'switch_statement',
    'switch_expression',
    'match_expression',
    'case_statement',
    'case_clause',
    'while_statement',
    'while_expression',
    'for_statement',
    'for_expression',
    'for_in_statement',
    'for_of_statement',
    'do_statement',
    'loop_expression',
    'repeat_statement',
    'try_statement',
    'catch_clause',
    'except_clause',
    'finally_clause',
    'block',
    'closure_expression',
    'lambda',
    'lambda_expression',
    'with_statement',
    'do_block',
  }

  return {
    around_function_definition = treesitter_motion('aF', 'Around Function Definition', function_nodes, false),
    inside_function_definition = treesitter_motion('iF', 'Inside Function Definition', function_nodes, true),
    around_class = treesitter_motion('aC', 'Around Class', class_nodes, false),
    inside_class = treesitter_motion('iC', 'Inside Class', class_nodes, true),
    around_scope = treesitter_motion('ao', 'Around Scope', scope_nodes, false),
    inside_scope = treesitter_motion('io', 'Inside Scope', scope_nodes, true),
  }
end

function M.setup()
  if M._registered then return end

  local smart_motion = require 'smart-motion'
  smart_motion.collectors.register('mini_ai_textobjects', collector, { override = true })
  smart_motion.motions.register_many(mini_motions(), { override = true })
  smart_motion.motions.register_many(treesitter_compat_motions(), { override = true })

  M._registered = true
end

return M
