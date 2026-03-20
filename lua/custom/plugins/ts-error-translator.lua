return {
  'dmmulroy/ts-error-translator.nvim',
  ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  config = function()
    require('ts-error-translator').setup {}
  end,
}
