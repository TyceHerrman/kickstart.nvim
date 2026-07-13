local pack = require 'custom.pack'

local specs = {
  pack.gh 'saghen/blink.lib',
  { src = pack.gh 'saghen/blink.pairs', version = vim.version.range '*' },
}

pack.build('blink.pairs', function()
  pcall(vim.cmd.packadd, 'blink.lib')
  pcall(vim.cmd.packadd, 'blink.pairs')
  require('blink.pairs').build():pwait(120000)
end)

local function setup()
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
