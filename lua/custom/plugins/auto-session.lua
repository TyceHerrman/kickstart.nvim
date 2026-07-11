local pack = require 'custom.pack'

local function quickfix_items()
  local qf = vim.fn.getqflist { items = 0, title = 0 }
  local items = {}

  for _, item in ipairs(qf.items or {}) do
    local filename = item.filename
    if (not filename or filename == '') and item.bufnr and item.bufnr > 0 then
      local ok, name = pcall(vim.api.nvim_buf_get_name, item.bufnr)
      if ok and name ~= '' then filename = name end
    end

    if filename and filename ~= '' then
      table.insert(items, {
        filename = filename,
        lnum = item.lnum,
        col = item.col,
        text = item.text,
        type = item.type,
        nr = item.nr,
        valid = item.valid,
      })
    end
  end

  if vim.tbl_isempty(items) then return nil end

  return {
    title = qf.title,
    items = items,
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

local function save_extra_data()
  local extra = {
    breakpoints = dap_breakpoints(),
    quickfix = quickfix_items(),
  }

  if not extra.breakpoints and not extra.quickfix then return nil end
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

local function restore_quickfix(quickfix)
  if type(quickfix) ~= 'table' or type(quickfix.items) ~= 'table' or vim.tbl_isempty(quickfix.items) then return end

  vim.fn.setqflist({}, 'r', {
    title = quickfix.title or 'AutoSession',
    items = quickfix.items,
  })
end

local function restore_extra_data(_, extra_data)
  local ok, extra = pcall(vim.fn.json_decode, extra_data)
  if not ok or type(extra) ~= 'table' then return end

  restore_quickfix(extra.quickfix)
  restore_breakpoints(extra.breakpoints)
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
