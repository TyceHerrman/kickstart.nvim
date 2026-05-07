local pack = require 'custom.pack'

local specs = {
  pack.gh 'saghen/blink.download',
  pack.gh 'saghen/blink.pairs',
}

local function setup()
  vim.api.nvim_set_hl(0, 'BlinkPairsOrange', { fg = '#FFB86C' })
  vim.api.nvim_set_hl(0, 'BlinkPairsPurple', { fg = '#BD93F9' })
  vim.api.nvim_set_hl(0, 'BlinkPairsBlue', { fg = '#8BE9FD' })
  vim.api.nvim_set_hl(0, 'BlinkPairsUnmatched', { fg = '#FF5555' })
  vim.api.nvim_set_hl(0, 'BlinkPairsMatchParen', { fg = '#F1FA8C', bold = true })

  require('blink.pairs').setup {
    mappings = {
      enabled = true,
      cmdline = true,
      disabled_filetypes = {},
      wrap = {
        ['<C-b>'] = 'motion',
        ['<C-S-b>'] = 'motion_reverse',
      },
      pairs = {},
    },
    highlights = {
      enabled = true,
      cmdline = true,
      groups = {
        'BlinkPairsOrange',
        'BlinkPairsPurple',
        'BlinkPairsBlue',
      },
      unmatched_group = 'BlinkPairsUnmatched',
      matchparen = {
        enabled = true,
        cmdline = false,
        include_surrounding = false,
        group = 'BlinkPairsMatchParen',
        priority = 250,
      },
    },
    debug = false,
  }
end

pack.on_very_lazy('blink.pairs', specs, setup)
