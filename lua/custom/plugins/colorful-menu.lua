local pack = require 'custom.pack'

pack.eager({ pack.gh 'xzbdmw/colorful-menu.nvim' }, function()
  require('colorful-menu').setup {
    -- Only vtsls has dedicated colorful-menu formatting in this config.
    -- emmylua_ls, vue_ls, and dockerls intentionally use fallback highlighting.
    ls = {
      vtsls = {
        extra_info_hl = '@comment',
      },
      fallback = true,
      fallback_extra_info_hl = '@comment',
    },
    max_width = 60,
  }
end)
