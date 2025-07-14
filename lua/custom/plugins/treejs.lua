return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  -- Only load when we try to use it
  cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
  -- Or lazy load on keys if you want direct access to treesj commands
  -- keys = {
  --   { '<leader>tj', '<cmd>TSJToggle<cr>', desc = 'TreeSJ Toggle' },
  -- },
  config = function()
    require('treesj').setup {
      use_default_keymaps = false, -- We're using custom keymaps
      check_syntax_error = true,
      max_join_length = 120,
      cursor_behavior = 'hold',
      notify = true,
      dot_repeat = true,
      -- Add any custom language configs here
      -- langs = {}
    }
  end,
}
