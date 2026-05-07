local pack = require 'custom.pack'

local specs = {
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'nvim-tree/nvim-web-devicons',
  pack.gh 'stevearc/aerial.nvim',
}

local load = pack.lazy('aerial.nvim', specs, function() require('aerial').setup {} end)

pack.on_event({ 'BufReadPost', 'BufNewFile' }, 'aerial.nvim', specs, function() require('aerial').setup {} end)

pack.keymaps({
  { '<leader>a', '<cmd>AerialToggle<CR>', desc = 'Toggle [A]erial' },
  {
    '<leader>fs',
    function() require('aerial').snacks_picker() end,
    desc = 'Find Symbols',
  },
}, load)
