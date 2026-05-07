local pack = require 'custom.pack'

local specs = {
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'Wansmer/treesj',
}

local function setup()
  require('treesj').setup {
    use_default_keymaps = false,
    check_syntax_error = true,
    max_join_length = 120,
    cursor_behavior = 'hold',
    notify = true,
    dot_repeat = true,
  }
end

pack.on_cmd({ 'TSJToggle', 'TSJSplit', 'TSJJoin' }, 'treesj', specs, setup)
