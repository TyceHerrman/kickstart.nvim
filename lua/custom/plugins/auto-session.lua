local pack = require 'custom.pack'

local function save_quickfix_cmds()
  local qflist = vim.fn.getqflist()
  if vim.tbl_isempty(qflist) then return nil end

  local qfinfo = vim.fn.getqflist { title = 1 }
  for _, entry in ipairs(qflist) do
    local bufnr = entry.bufnr
    if type(bufnr) == 'number' and bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename ~= '' then entry.filename = filename end
    end
    entry.bufnr = nil
  end

  return {
    'call setqflist(' .. vim.fn.string(qflist) .. ')',
    'call setqflist([], "a", ' .. vim.fn.string(qfinfo) .. ')',
    'copen',
  }
end

local function dap_breakpoints()
  local ok, breakpoints = pcall(require, 'dap.breakpoints')
  if not ok or not breakpoints then return nil end

  local by_file = {}
  for bufnr, buf_breakpoints in pairs(breakpoints.get()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= '' and type(buf_breakpoints) == 'table' and not vim.tbl_isempty(buf_breakpoints) then by_file[name] = buf_breakpoints end
  end

  if vim.tbl_isempty(by_file) then return nil end
  return by_file
end

local function kulala_env()
  local env = vim.g.kulala_selected_env
  if type(env) ~= 'string' or env == '' then return nil end
  return env
end

local function save_extra_data()
  local extra = {
    breakpoints = dap_breakpoints(),
    kulala_env = kulala_env(),
  }

  if not extra.breakpoints and not extra.kulala_env then return nil end
  return vim.fn.json_encode(extra)
end

local function restore_breakpoints(breakpoints_by_file)
  local ok, breakpoints = pcall(require, 'dap.breakpoints')
  if not ok or not breakpoints or type(breakpoints_by_file) ~= 'table' then return end

  for file, file_breakpoints in pairs(breakpoints_by_file) do
    local bufnr = vim.fn.bufnr(file, true)
    if vim.fn.bufloaded(bufnr) == 0 then vim.api.nvim_buf_call(bufnr, vim.cmd.edit) end

    for _, breakpoint in ipairs(file_breakpoints) do
      breakpoints.set({
        condition = breakpoint.condition,
        hit_condition = breakpoint.hitCondition,
        log_message = breakpoint.logMessage,
      }, bufnr, breakpoint.line)
    end
  end
end

local function restore_kulala_env(env)
  if type(env) ~= 'string' or env == '' then return end

  local kulala = package.loaded['kulala']
  if type(kulala) == 'table' and type(kulala.set_selected_env) == 'function' then
    local ok = pcall(kulala.set_selected_env, env)
    if ok then return end
  end

  vim.g.kulala_selected_env = env
end

local function restore_extra_data(_, extra_data)
  local ok, extra = pcall(vim.fn.json_decode, extra_data)
  if not ok or type(extra) ~= 'table' then return end

  restore_breakpoints(extra.breakpoints)
  restore_kulala_env(extra.kulala_env)
end

local specs = { pack.gh 'rmagatti/auto-session' }

pack.eager(specs, function()
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

  require('auto-session').setup {
    auto_save = true,
    auto_restore = true,
    auto_create = true,
    auto_restore_last_session = false,
    cwd_change_handling = true,
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
    auto_delete_empty_sessions = true,
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    bypass_save_filetypes = { 'snacks_dashboard', 'dashboard', 'alpha' },
    close_filetypes_on_save = { 'checkhealth', 'snacks_dashboard' },
    save_extra_cmds = { save_quickfix_cmds },
    save_extra_data = save_extra_data,
    restore_extra_data = restore_extra_data,
    session_lens = {
      picker = 'snacks',
      previewer = 'summary',
      picker_opts = {
        preset = 'dropdown',
        preview = false,
        layout = {
          width = 0.55,
          height = 0.55,
        },
      },
    },
  }

  pack.keymaps {
    { '<leader>wr', '<cmd>AutoSession search<cr>', desc = 'Session Search' },
    { '<leader>ws', '<cmd>AutoSession save<cr>', desc = 'Session Save' },
    { '<leader>wR', '<cmd>AutoSession restore<cr>', desc = 'Session Restore' },
    { '<leader>wd', '<cmd>AutoSession delete<cr>', desc = 'Session Delete Current' },
    { '<leader>wD', '<cmd>AutoSession deletePicker<cr>', desc = 'Session Delete Picker' },
    { '<leader>wa', '<cmd>AutoSession toggle<cr>', desc = 'Session Autosave Toggle' },
    { '<leader>wP', '<cmd>AutoSession purgeOrphaned<cr>', desc = 'Session Purge Orphaned' },
  }
end)
