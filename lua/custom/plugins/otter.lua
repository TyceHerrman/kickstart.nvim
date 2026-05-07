local pack = require 'custom.pack'

pack.eager({
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'jmbuhr/otter.nvim',
}, function() require('otter').setup {} end)
