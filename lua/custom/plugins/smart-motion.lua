local pack = require 'custom.pack'

pack.eager({ pack.gh 'FluxxField/smart-motion.nvim' }, function()
  require('smart-motion').setup {
    presets = {
      words = true,
      lines = true,
      search = true,
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
  require('custom.smart_motion_textobjects').setup()
end)
