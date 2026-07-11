local M = {}

local preview_ns = vim.api.nvim_create_namespace 'custom_git_hunk_preview'
local blame_ns = vim.api.nvim_create_namespace 'custom_git_line_blame'
local preview_win
local blame_enabled = {}
local blame_seq = 0

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = 'Git hunks' }) end

local function get_minidiff()
  local ok, minidiff = pcall(require, 'mini.diff')
  if ok then return minidiff end
  notify('mini.diff is not available', vim.log.levels.WARN)
end

local function get_buf_data()
  local minidiff = get_minidiff()
  if not minidiff then return nil end

  local data = minidiff.get_buf_data(0)
  if data == nil then
    notify('No mini.diff data for this buffer', vim.log.levels.INFO)
    return nil
  end
  return data
end

local function hunk_buf_range(hunk)
  if hunk.buf_count == 0 then
    local line = math.max(hunk.buf_start, 1)
    return line, line
  end
  return hunk.buf_start, hunk.buf_start + hunk.buf_count - 1
end

local function hunk_under_cursor(data)
  local line = vim.fn.line '.'
  for _, hunk in ipairs(data.hunks or {}) do
    local first, last = hunk_buf_range(hunk)
    if first <= line and line <= last then return hunk end
  end
end

local function visual_range()
  local first = vim.fn.line 'v'
  local last = vim.fn.line '.'
  if first > last then
    first, last = last, first
  end
  return first, last
end

local function do_hunks(action, range)
  local minidiff = get_minidiff()
  if not minidiff then return end

  local ok, err = pcall(minidiff.do_hunks, 0, action, range)
  if not ok then notify(tostring(err), vim.log.levels.WARN) end
end

local function current_line_range()
  local line = vim.fn.line '.'
  return { line_start = line, line_end = line }
end

local function split_ref_text(text)
  local lines = vim.split(text or '', '\n', { plain = true })
  if lines[#lines] == '' then table.remove(lines) end
  return lines
end

local function close_preview()
  if preview_win ~= nil and vim.api.nvim_win_is_valid(preview_win) then vim.api.nvim_win_close(preview_win, true) end
  preview_win = nil
end

local function preview_width(lines)
  local width = 20
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  return math.min(width + 2, math.max(20, vim.o.columns - 8))
end

local function open_preview(lines)
  close_preview()

  local max_height = math.max(1, math.floor(vim.o.lines * 0.6))
  if #lines > max_height then
    local clipped = vim.list_slice(lines, 1, max_height - 1)
    table.insert(clipped, string.format('... %d more lines', #lines - #clipped))
    lines = clipped
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'diff'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for i, line in ipairs(lines) do
    if line:sub(1, 1) == '-' then
      vim.api.nvim_buf_add_highlight(buf, preview_ns, 'DiffDelete', i - 1, 0, -1)
    elseif line:sub(1, 1) == '+' then
      vim.api.nvim_buf_add_highlight(buf, preview_ns, 'DiffAdd', i - 1, 0, -1)
    elseif line:sub(1, 2) == '@@' then
      vim.api.nvim_buf_add_highlight(buf, preview_ns, 'DiffText', i - 1, 0, -1)
    end
  end

  preview_win = vim.api.nvim_open_win(buf, false, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = preview_width(lines),
    height = #lines,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
    once = true,
    callback = close_preview,
  })
end

function M.preview_hunk()
  -- UPSTREAM-FOLLOW: no upstream mini.diff issue found for preview_hunk/popup hunk as of 2026-05-07; remove if MiniDiff gains native hunk preview.
  local data = get_buf_data()
  if data == nil then return end

  local hunk = hunk_under_cursor(data)
  if hunk == nil then
    notify 'No hunk under cursor'
    return
  end

  local ref_lines = split_ref_text(data.ref_text)
  local buf_start = math.max(hunk.buf_start - 1, 0)
  local buf_lines = hunk.buf_count > 0 and vim.api.nvim_buf_get_lines(0, buf_start, buf_start + hunk.buf_count, false) or {}

  local lines = {
    string.format('@@ -%d,%d +%d,%d @@', hunk.ref_start, hunk.ref_count, hunk.buf_start, hunk.buf_count),
  }

  for i = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
    table.insert(lines, '- ' .. (ref_lines[i] or ''))
  end
  for _, line in ipairs(buf_lines) do
    table.insert(lines, '+ ' .. line)
  end

  open_preview(lines)
end

local function git_root(file)
  local git_dir = vim.fs.find('.git', { path = vim.fs.dirname(file), upward = true })[1]
  if git_dir == nil then return nil end
  return vim.fs.dirname(git_dir)
end

local function relpath(root, file)
  if vim.fs.relpath then
    local ok, rel = pcall(vim.fs.relpath, root, file)
    if ok and rel ~= nil then return rel end
  end

  root = vim.fs.normalize(root)
  file = vim.fs.normalize(file)
  if file:sub(1, #root + 1) == root .. '/' then return file:sub(#root + 2) end
  return file
end

local function current_git_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    notify('Current buffer has no file', vim.log.levels.WARN)
    return nil
  end

  local root = git_root(file)
  if root == nil then
    notify('Current file is not in a Git repository', vim.log.levels.WARN)
    return nil
  end

  return root, relpath(root, file), file
end

local function parse_blame(lines)
  if #lines == 0 then return nil end

  local hash = lines[1]:match '^([^%s]+)'
  local author = 'unknown'
  local author_time
  local summary = ''

  for _, line in ipairs(lines) do
    author = line:match '^author (.+)' or author
    author_time = line:match '^author%-time (%d+)' or author_time
    summary = line:match '^summary (.+)' or summary
  end

  if hash ~= nil and hash:match '^0+$' then return 'Not committed yet' end

  local date = author_time and os.date('%Y-%m-%d', tonumber(author_time)) or 'unknown date'
  local short_hash = hash and hash:sub(1, 8) or 'unknown'
  return string.format('%s %s %s - %s', short_hash, author, date, summary)
end

local function has_haunt_annotation(buf, line)
  local haunt_ns = vim.api.nvim_get_namespaces().haunt
  if haunt_ns == nil then return false end

  local marks = vim.api.nvim_buf_get_extmarks(buf, haunt_ns, { line - 1, 0 }, { line - 1, -1 }, { details = true })
  for _, mark in ipairs(marks) do
    local details = mark[4]
    if details and details.virt_text then return true end
  end

  return false
end

local function update_line_blame(buf)
  if not blame_enabled[buf] or not vim.api.nvim_buf_is_valid(buf) then return end

  vim.api.nvim_buf_clear_namespace(buf, blame_ns, 0, -1)

  local file = vim.api.nvim_buf_get_name(buf)
  if file == '' then return end

  local root = git_root(file)
  if root == nil then return end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local has_visible_haunt_note = has_haunt_annotation(buf, line)

  local lines = vim.fn.systemlist { 'git', '-C', root, 'blame', '-L', line .. ',' .. line, '--porcelain', '--', relpath(root, file) }
  if vim.v.shell_error ~= 0 then return end

  local blame = parse_blame(lines)
  if blame == nil then return end

  if has_visible_haunt_note then
    vim.api.nvim_buf_set_extmark(buf, blame_ns, line - 1, 0, {
      virt_lines = { { { '  ' .. blame, 'Comment' } } },
      virt_lines_above = false,
    })
  else
    vim.api.nvim_buf_set_extmark(buf, blame_ns, line - 1, 0, {
      virt_text = { { '  ' .. blame, 'Comment' } },
      virt_text_pos = 'eol_right_align',
    })
  end
end

local function schedule_line_blame(buf)
  blame_seq = blame_seq + 1
  local seq = blame_seq

  vim.defer_fn(function()
    if seq ~= blame_seq then return end
    update_line_blame(buf)
  end, 200)
end

function M.toggle_line_blame()
  -- UPSTREAM-FOLLOW: replace if mini.git lands line blame; see nvim-mini/mini.nvim#2174, discussions #2029/#2305.
  local buf = vim.api.nvim_get_current_buf()
  blame_enabled[buf] = not blame_enabled[buf]
  vim.api.nvim_buf_clear_namespace(buf, blame_ns, 0, -1)

  if blame_enabled[buf] then
    schedule_line_blame(buf)
    notify 'Inline Git blame enabled'
  else
    notify 'Inline Git blame disabled'
  end
end

local function git_show(revision, rel)
  if revision == 'index' then return ':' .. rel end
  return revision .. ':' .. rel
end

local function scratch_name(revision, rel) return string.format('mini-git://%s/%s', revision, rel) end

function M.diff_file(revision)
  -- UPSTREAM-FOLLOW: exact Diffview/diffthis UX is intentionally not mini.diff's direction; see discussion #2136 and #1333.
  -- Maintainer context: "I am afraid, no, not really. There is built-in :h diff that can show the differences. For me an overlay feels more practical."
  local root, rel = current_git_file()
  if root == nil then return end

  local object = git_show(revision, rel)
  local lines = vim.fn.systemlist { 'git', '-C', root, 'show', object }
  if vim.v.shell_error ~= 0 then
    notify('Could not read ' .. object, vim.log.levels.WARN)
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].bufhidden = 'wipe'
  vim.bo[scratch].swapfile = false
  vim.bo[scratch].filetype = vim.bo[current_buf].filetype
  pcall(vim.api.nvim_buf_set_name, scratch, scratch_name(revision, rel))
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
  vim.bo[scratch].modifiable = false

  vim.cmd 'diffthis'
  vim.cmd 'vsplit'
  vim.api.nvim_win_set_buf(0, scratch)
  vim.cmd 'diffthis'
  vim.api.nvim_set_current_win(current_win)
end

function M.current_qflist()
  local minidiff = get_minidiff()
  if not minidiff then return end

  local qf = minidiff.export('qf', { scope = 'current' })
  if #qf == 0 then
    notify 'No hunks in current buffer'
    return
  end

  vim.fn.setqflist(qf, 'r')
  local ok, trouble = pcall(require, 'trouble')
  if ok then
    trouble.open { mode = 'qflist' }
  else
    vim.cmd 'copen'
  end
end

function M.repo_hunks() Snacks.picker.git_diff { group = false } end

function M.staged_hunks()
  -- UPSTREAM-FOLLOW: mini.diff does not support staged hunk signs/unstage; see discussion #2052 and #2137.
  Snacks.picker.git_diff { group = false, staged = true }
end

function M.blame_line() Snacks.git.blame_line() end

function M.toggle_overlay()
  local minidiff = get_minidiff()
  if minidiff then
    local ok, err = pcall(minidiff.toggle_overlay, 0)
    if not ok then notify(tostring(err), vim.log.levels.WARN) end
  end
end

function M.setup()
  local function goto_hunk(direction)
    local ok, err = pcall(require('mini.diff').goto_hunk, direction)
    if not ok then notify(tostring(err), vim.log.levels.WARN) end
  end

  vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      goto_hunk 'next'
    end
  end, { desc = 'Next git hunk' })

  vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      goto_hunk 'prev'
    end
  end, { desc = 'Previous git hunk' })

  vim.keymap.set('n', '<leader>hs', function() do_hunks('apply', current_line_range()) end, { desc = 'git [s]tage hunk' })

  vim.keymap.set('n', '<leader>hr', function() do_hunks('reset', current_line_range()) end, { desc = 'git [r]eset hunk' })

  vim.keymap.set('v', '<leader>hs', function()
    local first, last = visual_range()
    do_hunks('apply', { line_start = first, line_end = last })
  end, { desc = 'git [s]tage hunk' })

  vim.keymap.set('v', '<leader>hr', function()
    local first, last = visual_range()
    do_hunks('reset', { line_start = first, line_end = last })
  end, { desc = 'git [r]eset hunk' })

  vim.keymap.set('n', '<leader>hS', function() do_hunks 'apply' end, { desc = 'git [S]tage buffer' })

  vim.keymap.set('n', '<leader>hR', function() do_hunks 'reset' end, { desc = 'git [R]eset buffer' })

  vim.keymap.set('n', '<leader>hp', M.preview_hunk, { desc = 'git [p]review hunk' })
  vim.keymap.set('n', '<leader>hi', M.toggle_overlay, { desc = 'git preview hunk [i]nline' })
  vim.keymap.set('n', '<leader>hb', M.blame_line, { desc = 'git [b]lame line' })
  vim.keymap.set('n', '<leader>hd', function() M.diff_file 'index' end, { desc = 'git [d]iff against index' })
  vim.keymap.set('n', '<leader>hD', function() M.diff_file 'HEAD' end, { desc = 'git [D]iff against last commit' })
  vim.keymap.set('n', '<leader>hQ', M.repo_hunks, { desc = 'git hunk [Q]uickfix list (repo picker)' })
  vim.keymap.set('n', '<leader>hq', M.current_qflist, { desc = 'git hunk [q]uickfix list (current file)' })
  vim.keymap.set('n', '<leader>hu', M.staged_hunks, { desc = 'git [u]nstage hunk (picker)' })
  vim.keymap.set('n', '<leader>tb', M.toggle_line_blame, { desc = '[T]oggle git show [b]lame line' })
  vim.keymap.set('n', '<leader>tw', M.toggle_overlay, { desc = '[T]oggle git intra-line [w]ord diff' })
  vim.keymap.set({ 'o', 'x' }, 'ih', function()
    local ok, err = pcall(require('mini.diff').textobject)
    if not ok then notify(tostring(err), vim.log.levels.WARN) end
  end, { desc = 'Git hunk textobject' })

  local group = vim.api.nvim_create_augroup('CustomGitLineBlame', { clear = true })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufEnter' }, {
    group = group,
    callback = function(args)
      if blame_enabled[args.buf] then schedule_line_blame(args.buf) end
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'BufWipeout' }, {
    group = group,
    callback = function(args)
      if vim.api.nvim_buf_is_valid(args.buf) then vim.api.nvim_buf_clear_namespace(args.buf, blame_ns, 0, -1) end
      if args.event == 'BufWipeout' then blame_enabled[args.buf] = nil end
    end,
  })
end

return M
