local pack = require 'custom.pack'

local specs = { pack.gh 'TheNoeTrevino/haunt.nvim' }

local function setup()
  require('haunt').setup {
    virt_text_pos = 'eol_right_align',
    virt_text_hl = 'Comment',
    annotation_prefix = '  [haunt] ',
    picker = 'snacks',
    per_branch_bookmarks = true,
    data_dir = nil,
  }
end

local load = pack.lazy('haunt.nvim', specs, setup)

pack.keymaps({
  { '<leader>mha', '<cmd>HauntAnnotate<CR>', desc = 'Haunt annotate line' },
  { '<leader>mhd', '<cmd>HauntDelete<CR>', desc = 'Haunt delete annotation' },
  { '<leader>mhn', '<cmd>HauntNext<CR>', desc = 'Haunt next annotation' },
  { '<leader>mhp', '<cmd>HauntPrev<CR>', desc = 'Haunt previous annotation' },
  { '<leader>mhl', '<cmd>HauntList<CR>', desc = 'Haunt list annotations' },
  {
    '<leader>mhT',
    function() require('haunt.api').toggle_all_lines() end,
    desc = 'Haunt toggle all annotations',
  },
}, load)
