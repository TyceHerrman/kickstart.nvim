local pack = require 'custom.pack'

pack.eager({ pack.gh 'FluxxField/smart-motion.nvim' }, function()
  require('smart-motion').setup {
    presets = {
      words = true,
      lines = true,
      search = { s = false },
      delete = true,
      yank = true,
      change = true,
      paste = true,
      treesitter = true,
      diagnostics = true,
      git = true,
      quickfix = true,
      marks = true,
      misc = true,
    },
  }
  require('smart-motion').motions.register_many {
    ['g/'] = {
      collector = 'lines',
      extractor = 'live_search',
      filter = 'filter_words_after_cursor',
      visualizer = 'hint_start',
      action = 'jump_centered',
      map = true,
      modes = { 'n', 'o' },
      metadata = {
        label = 'Live Search',
        description = 'Live search after the cursor',
        motion_state = {
          multi_window = true,
        },
      },
    },
  }
  require('custom.smart_motion_textobjects').setup()
end)
