return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'johnseth97/gh-dash.nvim' },

  opts = {
    options = {
      theme = 'dracula',
    },
    sections = {
    -- this extends the defaults   [oai_citation:1‡GitHub](https://github.com/nvim-lualine/lualine.nvim?utm_source=chatgpt.com)
      lualine_x = {
      -- live indicator; re-evaluated each redraw
        function()
          local ok, dash = pcall(require, 'gh-dash')
          return ok and dash.status() or ''
        end,
        'encoding',
        'filetype',
      },
    },
  },
}
