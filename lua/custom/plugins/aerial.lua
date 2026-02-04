return {
  'stevearc/aerial.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>a', '<cmd>AerialToggle<CR>', desc = 'Toggle [A]erial' },
    {
      '<leader>fs',
      function()
        require('aerial').snacks_picker()
      end,
      desc = 'Find Symbols',
    },
    { '<leader>ds', '<cmd>call aerial#fzf()<CR>', desc = 'Aerial FZF' },
  },
  opts = {},
}
