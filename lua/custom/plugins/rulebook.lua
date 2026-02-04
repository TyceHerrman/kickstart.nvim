return {
  'chrisgrieser/nvim-rulebook',
  event = 'LspAttach',
  keys = {
    {
      '<leader>rl',
      function()
        require('rulebook').lookupRule()
      end,
      desc = 'Lookup rule docs',
    },
    {
      '<leader>ri',
      function()
        require('rulebook').ignoreRule()
      end,
      desc = 'Add ignore comment (linter)',
    },
    {
      '<leader>rs',
      function()
        require('rulebook').suppressFormatter()
      end,
      desc = 'Add ignore comment (formatter)',
    },
    {
      '<leader>ry',
      function()
        require('rulebook').yankDiagnosticCode()
      end,
      desc = 'Yank diagnostic code',
    },
  },
}
