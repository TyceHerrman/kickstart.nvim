local pack = require 'custom.pack'

pack.eager({
  pack.gh 'nvim-mini/mini.nvim',
  pack.gh 'OXY2DEV/markview.nvim',
}, function()
  require('markview').setup {
    preview = {
      icon_provider = 'mini',
    },
  }
end)
