return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = "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"
            },
          })
        end,
      },
    },
  },
}
