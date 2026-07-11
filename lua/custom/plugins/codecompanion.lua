local pack = require 'custom.pack'

pack.eager({
  -- Upstream plenary removal tracking:
  --   Discussions: https://github.com/olimorris/codecompanion.nvim/discussions/3027
  --                https://github.com/olimorris/codecompanion.nvim/discussions/3016
  --   Partial PR: https://github.com/olimorris/codecompanion.nvim/pull/1642
  pack.gh 'nvim-lua/plenary.nvim',
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'olimorris/codecompanion.nvim',
}, function()
  require('codecompanion').setup {
    adapters = {
      acp = {
        claude_code = function()
          return require('codecompanion.adapters').extend('claude_code', {
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = '',
            },
          })
        end,
      },
    },
  }
end)
