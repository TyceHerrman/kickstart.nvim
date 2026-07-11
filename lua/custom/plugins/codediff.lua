local pack = require 'custom.pack'

local specs = {
  pack.gh 'esmuellert/codediff.nvim',
}

local base_candidates = {
  'origin/main',
  'upstream/main',
  'main',
  'origin/master',
  'upstream/master',
  'master',
}

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = 'CodeDiff' }) end

local function git_root()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local cwd = vim.uv.cwd()
  local path = buf_name ~= '' and vim.fs.dirname(buf_name) or cwd

  local result = vim.system({ 'git', '-C', path, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  if result.code == 0 then return vim.trim(result.stdout) end

  result = vim.system({ 'git', '-C', cwd, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  if result.code == 0 then return vim.trim(result.stdout) end

  notify('Current buffer is not in a Git repository', vim.log.levels.WARN)
  return nil
end

local function git(root, args) return vim.system(vim.list_extend({ 'git', '-C', root }, args), { text = true }):wait() end

local function detect_base()
  local root = git_root()
  if not root then return nil end

  for _, candidate in ipairs(base_candidates) do
    if git(root, { 'rev-parse', '--verify', '--quiet', candidate }).code == 0 then return candidate end
  end

  notify('No review base found: origin/main, upstream/main, main, origin/master, upstream/master, or master', vim.log.levels.WARN)
  return nil
end

local function code_diff(args)
  local suffix = args and args ~= '' and (' ' .. args) or ''
  vim.cmd('CodeDiff' .. suffix)
end

local function setup()
  require('codediff').setup {
    highlights = {
      line_insert = 'DiffAdd',
      line_delete = 'DiffDelete',
      char_insert = nil,
      char_delete = nil,
      char_brightness = nil,
      conflict_sign = 'DiagnosticSignWarn',
      conflict_sign_resolved = 'Comment',
      conflict_sign_accepted = 'DiagnosticSignOk',
      conflict_sign_rejected = 'DiagnosticSignError',
    },
    diff = {
      layout = 'side-by-side',
      disable_inlay_hints = true,
      max_computation_time_ms = 5000,
      ignore_trim_whitespace = false,
      hide_merge_artifacts = true,
      original_position = 'left',
      conflict_ours_position = 'right',
      conflict_result_position = 'bottom',
      conflict_result_height = 30,
      conflict_result_width_ratio = { 1, 1, 1 },
      cycle_next_hunk = true,
      cycle_next_file = true,
      jump_to_first_change = true,
      highlight_priority = 100,
      compute_moves = true,
    },
    explorer = {
      position = 'left',
      width = 42,
      height = 15,
      indent_markers = true,
      initial_focus = 'explorer',
      view_mode = 'tree',
      flatten_dirs = true,
      file_filter = {
        ignore = { '.git/**', '.jj/**' },
      },
      focus_on_select = false,
      visible_groups = {
        staged = true,
        unstaged = true,
        conflicts = true,
      },
    },
    history = {
      position = 'bottom',
      width = 42,
      height = 16,
      initial_focus = 'history',
      view_mode = 'tree',
    },
    keymaps = {
      view = {
        quit = 'q',
        toggle_explorer = 'b',
        focus_explorer = 'e',
        next_hunk = ']c',
        prev_hunk = '[c',
        next_file = ']f',
        prev_file = '[f',
        diff_get = 'do',
        diff_put = 'dp',
        open_in_prev_tab = 'gf',
        close_on_open_in_prev_tab = false,
        toggle_stage = '-',
        stage_hunk = 'hs',
        unstage_hunk = 'hu',
        discard_hunk = 'hr',
        hunk_textobject = 'ih',
        show_help = 'g?',
        align_move = 'gm',
        toggle_layout = 't',
      },
      explorer = {
        select = '<CR>',
        hover = 'K',
        refresh = 'R',
        toggle_view_mode = 'i',
        stage_all = 'S',
        unstage_all = 'U',
        restore = 'X',
        toggle_changes = 'gu',
        toggle_staged = 'gs',
        fold_open = 'zo',
        fold_open_recursive = 'zO',
        fold_close = 'zc',
        fold_close_recursive = 'zC',
        fold_toggle = 'za',
        fold_toggle_recursive = 'zA',
        fold_open_all = 'zR',
        fold_close_all = 'zM',
      },
      history = {
        select = '<CR>',
        toggle_view_mode = 'i',
        refresh = 'R',
        fold_open = 'zo',
        fold_open_recursive = 'zO',
        fold_close = 'zc',
        fold_close_recursive = 'zC',
        fold_toggle = 'za',
        fold_toggle_recursive = 'zA',
        fold_open_all = 'zR',
        fold_close_all = 'zM',
      },
      conflict = {
        accept_incoming = 'ct',
        accept_current = 'co',
        accept_both = 'cb',
        discard = 'cx',
        accept_all_incoming = 'cT',
        accept_all_current = 'cO',
        accept_all_both = 'cB',
        discard_all = 'cX',
        next_conflict = ']x',
        prev_conflict = '[x',
        diffget_incoming = '2do',
        diffget_current = '3do',
      },
    },
  }
end

local load = pack.lazy('codediff.nvim', specs, setup)
local loaded = vim.g.loaded_codediff == 1 and vim.fn.exists ':CodeDiff' == 2

local function load_codediff()
  if loaded then return end
  if vim.g.loaded_codediff == 1 and vim.fn.exists ':CodeDiff' == 2 then
    loaded = true
    return
  end

  pcall(vim.api.nvim_del_user_command, 'CodeDiff')
  load()
  vim.cmd.runtime 'plugin/codediff.lua'
  loaded = true
end

local function open(args)
  load_codediff()
  code_diff(args)
end

local function with_base(pattern)
  return function()
    local base = detect_base()
    if base then open(pattern(base)) end
  end
end

if not loaded then
  vim.api.nvim_create_user_command('CodeDiff', function(args)
    load_codediff()

    local range = args.range and args.range > 0 and (args.line1 .. ',' .. args.line2) or ''
    local bang = args.bang and '!' or ''
    local suffix = args.args ~= '' and (' ' .. args.args) or ''
    vim.cmd(range .. 'CodeDiff' .. bang .. suffix)
  end, { bang = true, nargs = '*', complete = 'file', range = true })
end

pack.keymaps {
  { '<leader>gvc', function() open() end, desc = 'CodeDiff changed files' },
  { '<leader>gvi', function() open '--inline' end, desc = 'CodeDiff changed files inline' },
  { '<leader>gvb', with_base(function(base) return base .. '...' end), desc = 'CodeDiff branch review' },
  { '<leader>gvB', with_base(function(base) return base .. '...HEAD' end), desc = 'CodeDiff committed branch review' },
  { '<leader>gvf', function() open 'file HEAD' end, desc = 'CodeDiff file vs HEAD' },
  { '<leader>gvF', with_base(function(base) return 'file ' .. base .. '...HEAD' end), desc = 'CodeDiff file branch review' },
  { '<leader>gvh', function() open 'history' end, desc = 'CodeDiff history' },
  { '<leader>gvH', with_base(function(base) return 'history ' .. base .. '..HEAD --reverse' end), desc = 'CodeDiff branch history' },
  { '<leader>gvl', function() open 'history %' end, desc = 'CodeDiff file history' },
  {
    '<leader>gvl',
    function()
      load_codediff()
      vim.cmd "'<,'>CodeDiff history %"
    end,
    desc = 'CodeDiff selection history',
    mode = 'x',
  },
  { '<leader>gvm', function() open 'merge %' end, desc = 'CodeDiff merge current file' },
}
