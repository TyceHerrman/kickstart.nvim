local pack = require 'custom.pack'

pack.eager({
  pack.gh 'nvim-tree/nvim-web-devicons',
  pack.gh 'DaikyXendo/nvim-material-icon',
}, function()
  require('nvim-web-devicons').setup {
    default = true,
    strict = true,
  }
end)
