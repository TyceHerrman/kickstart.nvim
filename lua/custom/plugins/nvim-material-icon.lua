local pack = require 'custom.pack'

pack.eager({
  pack.gh 'DaikyXendo/nvim-material-icon',
}, function()
  require('nvim-web-devicons').setup {
    default = true,
    strict = true,
  }
end)
