local pack = require 'custom.pack'

pack.on_ft(
  'markdown',
  'obsidian.nvim',
  {
    pack.gh 'obsidian-nvim/obsidian.nvim',
  },
  function()
    require('obsidian').setup {
      legacy_commands = false,
      workspaces = {
        {
          name = 'personal',
          path = '~/obsidian/Obsidian Vault',
        },
      },
    }
  end
)
