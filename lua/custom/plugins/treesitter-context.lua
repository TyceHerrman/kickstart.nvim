local pack = require 'custom.pack'

local specs = {
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'nvim-treesitter/nvim-treesitter-context',
}

local function setup()
  local ui_filetypes = require 'custom.ui_filetypes'

  require('treesitter-context').setup {
    enable = true,
    multiwindow = true,
    max_lines = 4,
    min_window_height = 12,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = 'outer',
    mode = 'cursor',
    separator = '─',
    zindex = 20,
    on_attach = function(buf) return not ui_filetypes.should_skip_treesitter(buf) end,
  }
end

local load = pack.lazy('nvim-treesitter-context', specs, setup)

pack.on_event({ 'BufReadPost', 'BufNewFile' }, 'nvim-treesitter-context', specs, setup)
pack.on_cmd({ 'TSContext' }, 'nvim-treesitter-context', specs, setup)
pack.keymaps({
  {
    'gC',
    function() require('treesitter-context').go_to_context(vim.v.count1) end,
    desc = 'Go to Tree-sitter context',
  },
  { '<leader>uct', '<cmd>TSContext toggle<cr>', desc = 'Toggle Tree-sitter Context' },
}, load)
