return {
  'dmmulroy/ts-error-translator.nvim',
  ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  config = function()
    require('ts-error-translator').setup {
      -- Automatically override publish_diagnostics handler
      -- This translates TypeScript errors into plain English
      auto_override_publish_diagnostics = true,
    }
  end,
}
