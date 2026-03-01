return {
  'saghen/blink.pairs',
  event = 'VeryLazy',
  version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  dependencies = 'saghen/blink.download',
  -- OR build from source, requires nightly:
  -- https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  --- @module 'blink.pairs'
  --- @type blink.pairs.Config
  opts = {
    mappings = {
      -- you can call require("blink.pairs.mappings").enable()
      -- and require("blink.pairs.mappings").disable()
      -- to enable/disable mappings at runtime
      enabled = true,
      cmdline = true,
      -- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
      -- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
      disabled_filetypes = {},
      -- see the defaults:
      -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
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

      -- highlights matching pairs under the cursor
      matchparen = {
        enabled = true,
        -- known issue where typing won't update matchparen highlight, disabled by default
        cmdline = false,
        -- also include pairs not on top of the cursor, but surrounding the cursor
        include_surrounding = false,
        group = 'BlinkPairsMatchParen',
        priority = 250,
      },
    },
    debug = false,
  },
  config = function(_, opts)
    -- Define Dracula-themed highlights
    vim.api.nvim_set_hl(0, 'BlinkPairsOrange', { fg = '#FFB86C' })
    vim.api.nvim_set_hl(0, 'BlinkPairsPurple', { fg = '#BD93F9' })
    vim.api.nvim_set_hl(0, 'BlinkPairsBlue', { fg = '#8BE9FD' })
    vim.api.nvim_set_hl(0, 'BlinkPairsUnmatched', { fg = '#FF5555' }) -- Red
    vim.api.nvim_set_hl(0, 'BlinkPairsMatchParen', { fg = '#F1FA8C', bold = true }) -- Yellow

    require('blink.pairs').setup(opts)
  end,
}
