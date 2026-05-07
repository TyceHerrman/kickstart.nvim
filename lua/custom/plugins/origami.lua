local pack = require 'custom.pack'

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

pack.on_very_lazy('nvim-origami', { pack.gh 'chrisgrieser/nvim-origami' }, function() require('origami').setup {} end)
