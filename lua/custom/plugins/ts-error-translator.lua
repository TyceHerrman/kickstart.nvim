local pack = require 'custom.pack'

pack.on_ft(
  { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  'ts-error-translator.nvim',
  { pack.gh 'dmmulroy/ts-error-translator.nvim' },
  function() require('ts-error-translator').setup {} end
)
