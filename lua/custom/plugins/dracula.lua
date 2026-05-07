local pack = require 'custom.pack'

pack.eager({ pack.gh 'binhtran432k/dracula.nvim' }, function()
  vim.o.background = 'dark'
  vim.cmd.colorscheme 'dracula'
end)
