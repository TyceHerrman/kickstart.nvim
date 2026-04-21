return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  opts = {
    picker = 'snacks',
    enable_builtin = true,
    use_local_fs = true,
    ui = {
      use_signcolumn = true,
    },
    runs = {
      icons = {
        pending = '',
        in_progress = '',
        failed = '',
        succeeded = '',
        skipped = '',
        cancelled = '󰜺',
      },
    },
    colors = {
      white = '#F8F8F2',
      grey = '#6272A4',
      black = '#282A36',
      red = '#FF5555',
      dark_red = '#FF5555',
      green = '#50FA7B',
      dark_green = '#50FA7B',
      yellow = '#F1FA8C',
      dark_yellow = '#FFB86C',
      blue = '#8BE9FD',
      dark_blue = '#6272A4',
      purple = '#BD93F9',
    },
  },
  keys = {
    { '<leader>oi', '<cmd>Octo issue list<CR>', desc = 'List GitHub Issues' },
    { '<leader>op', '<cmd>Octo pr list<CR>', desc = 'List GitHub Pull Requests' },
    { '<leader>od', '<cmd>Octo discussion list<CR>', desc = 'List GitHub Discussions' },
    { '<leader>on', '<cmd>Octo notification list<CR>', desc = 'List GitHub Notifications' },
    {
      '<leader>os',
      function() require('octo.utils').create_base_search_command { include_current_repo = true } end,
      desc = 'Search GitHub',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
  },
}
