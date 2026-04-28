return {
  'OXY2DEV/markview.nvim',
  lazy = false,
  priority = 900,
  dependencies = {
    'nvim-mini/mini.nvim',
  },
  opts = {
    preview = {
      icon_provider = 'mini',
    },
  },
}
