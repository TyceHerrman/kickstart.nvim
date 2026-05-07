local pack = require 'custom.pack'

pack.eager({
  pack.gh 'MunifTanjim/nui.nvim',
  pack.gh 'm4xshen/hardtime.nvim',
}, function()
  require('hardtime').setup {
    restricted_keys = {
      j = false,
      k = false,
    },
  }
end)
