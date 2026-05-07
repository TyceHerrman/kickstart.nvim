local pack = require 'custom.pack'

pack.eager({ pack.gh 'saghen/blink.indent' }, function()
  -- Define Dracula-themed highlight groups
  vim.api.nvim_set_hl(0, 'BlinkIndentOrange', { fg = '#FFB86C' })
  vim.api.nvim_set_hl(0, 'BlinkIndentPurple', { fg = '#BD93F9' })
  vim.api.nvim_set_hl(0, 'BlinkIndentCyan', { fg = '#8BE9FD' })
  vim.api.nvim_set_hl(0, 'BlinkIndentPink', { fg = '#FF79C6' })
  vim.api.nvim_set_hl(0, 'BlinkIndentGreen', { fg = '#50FA7B' })

  require('blink.indent').setup {
    scope = {
      highlights = {
        'BlinkIndentOrange',
        'BlinkIndentPurple',
        'BlinkIndentCyan',
        'BlinkIndentPink',
        'BlinkIndentGreen',
      },
    },
  }
end)
