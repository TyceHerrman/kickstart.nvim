local pack = require 'custom.pack'

pack.on_ft({ 'typescript', 'typescriptreact' }, 'ts-expand-hover.nvim', { pack.gh 'nemanjamalesija/ts-expand-hover.nvim' }, function()
  require('ts-expand-hover').setup {
    -- Recommended: avoid conflicts with distros/plugins that already map `K`
    keymaps = { hover = '<leader>th' },
  }
end)
