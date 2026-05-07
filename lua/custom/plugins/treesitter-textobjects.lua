local pack = require 'custom.pack'

vim.g.no_plugin_maps = true

pack.eager { { src = pack.gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' } }
