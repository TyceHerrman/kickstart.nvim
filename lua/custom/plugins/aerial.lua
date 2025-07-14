return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>ta', '<cmd>AerialToggle<CR>', desc = '[T]oggle [A]erial' },
    {
      '<leader>fs',
      function()
        require('aerial').snacks_picker()
      end,
      desc = 'Find Symbols',
    },
  },
  opts = {},
}
