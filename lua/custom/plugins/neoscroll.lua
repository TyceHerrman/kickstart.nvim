local pack = require 'custom.pack'

pack.eager({ pack.gh 'karb94/neoscroll.nvim' }, function() require('neoscroll').setup {} end)
