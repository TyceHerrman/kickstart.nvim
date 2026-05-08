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
              CLAUDE_CODE_OAUTH_TOKEN = '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',
            },
          })
        end,
      },
    },
  }
end)
