local pack = require 'custom.pack'

local specs = {
  -- Upstream plenary removal tracking:
  --   Issue: https://github.com/pwntester/octo.nvim/issues/909
  --   Discussion: https://github.com/pwntester/octo.nvim/discussions/876
  pack.gh 'nvim-lua/plenary.nvim',
  pack.gh 'folke/snacks.nvim',
  -- File panel icons use Octo's callback API added in #1512.
  -- mini.icons is already loaded by the core mini.nvim setup.
  pack.gh 'pwntester/octo.nvim',
}

local function setup()
  require('octo').setup {
    -- UPSTREAM-FOLLOW: Octo Snacks picker coverage, checked 2026-05-09.
    -- Keep direct Snacks where implemented; Octo falls back to the default
    -- provider for absent picker keys. Direct discussion trackers were not
    -- found; weak related discussions: #1009 (custom commands), #1435 (repos).
    -- Umbrella: https://github.com/pwntester/octo.nvim/issues/1027
    -- Fallback/default: #855, #1323, #1493.
    -- actions: #1028, closed PR #1129, merged PR #1060.
    -- discussions: #1033; gists: #1034; pending_threads: #1038.
    -- project_cards_v2: #1040; project_columns_v2: #1042.
    -- repos: #1043 and #1052; workflow_runs: #1044; milestones: #1048.
    -- No direct Snacks tracker found: comment_edits (command PR #1463),
    -- releases (generic command issue #1089).
    picker = 'snacks',
    enable_builtin = true,
    use_local_fs = true,
    file_panel = {
      icons = function(name, _ext) return require('mini.icons').get('file', name) end,
    },
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
  }
end

local load = pack.lazy('octo.nvim', specs, setup)

pack.on_cmd('Octo', 'octo.nvim', specs, setup)
pack.keymaps({
  { '<leader>oi', '<cmd>Octo issue list<CR>', desc = 'List GitHub Issues' },
  { '<leader>op', '<cmd>Octo pr list<CR>', desc = 'List GitHub Pull Requests' },
  { '<leader>od', '<cmd>Octo discussion list<CR>', desc = 'List GitHub Discussions' },
  { '<leader>on', '<cmd>Octo notification list<CR>', desc = 'List GitHub Notifications' },
  {
    '<leader>os',
    function() require('octo.utils').create_base_search_command { include_current_repo = true } end,
    desc = 'Search GitHub',
  },
}, load)
