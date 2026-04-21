return {
  {
    dir = "/Users/tyceherrman/GitHub/forks/colorful-menu.nvim",
    name = "colorful-menu.nvim",
    opts = {
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
  },
  },
}
