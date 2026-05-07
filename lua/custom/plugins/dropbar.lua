local pack = require 'custom.pack'

pack.build('telescope-fzf-native.nvim', 'make')
pack.eager({
  pack.gh 'nvim-telescope/telescope-fzf-native.nvim',
  pack.gh 'nvim-tree/nvim-web-devicons',
  pack.gh 'Bekaboo/dropbar.nvim',
}, function()
  local dropbar_api = require 'dropbar.api'
  vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
  vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
  vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
end)
