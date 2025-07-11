return {
  'DaikyXendo/nvim-material-icon',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('nvim-web-devicons').setup {
      -- globally enable default icons (default to false)
      default = true,
      -- globally enable "strict" selection of icons - icon will be looked up in
      -- different tables, first by filename, and if not found by extension:
      strict = true,
    }
  end,
}
