local pending_like_cli_open = false

local function reset_window_local_defaults()
  for _, option in ipairs {
    'colorcolumn',
    'cursorcolumn',
    'cursorline',
    'foldcolumn',
    'list',
    'number',
    'relativenumber',
    'signcolumn',
    'spell',
    'statuscolumn',
    'winhighlight',
    'wrap',
  } do
    pcall(vim.cmd, ('setlocal %s<'):format(option))
  end
end

local function mark_next_yazi_open(chosen_file)
  if chosen_file then
    pending_like_cli_open = true
  end
end

local function setup_yazi_cli_open_autocmd()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('custom-yazi-cli-open', { clear = true }),
    callback = function(args)
      if not pending_like_cli_open or vim.bo[args.buf].buftype ~= '' then
        return
      end

      pending_like_cli_open = false
      reset_window_local_defaults()
    end,
  })
end

return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '<leader>-',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig | {}
  opts = function()
    setup_yazi_cli_open_autocmd()

    return {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
      hooks = {
        yazi_closed_successfully = function(chosen_file)
          mark_next_yazi_open(chosen_file)
        end,
        yazi_opened_multiple_files = function(chosen_files)
          if #chosen_files == 0 then
            return
          end

          pending_like_cli_open = true
          require('yazi.openers').open_multiple_files(chosen_files)
        end,
      },
    }
  end,
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    -- vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
}
