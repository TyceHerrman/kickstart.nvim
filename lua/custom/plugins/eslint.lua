return {
  'esmuellert/nvim-eslint',
  config = function()
    require('nvim-eslint').setup {
      settings = {
        workspaceFolder = function(bufnr)
          local workspace_dir = vim.fs.root(bufnr, { '.git' })
            or vim.fs.root(bufnr, { 'package.json' })
            or vim.fs.root(bufnr, {
              'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs',
              'eslint.config.ts', 'eslint.config.mts', 'eslint.config.cts',
              '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.mjs',
              '.eslintrc.json', '.eslintrc.yaml', '.eslintrc.yml',
            })
            or vim.fn.getcwd()
          return {
            uri = vim.uri_from_fname(workspace_dir),
            name = vim.fn.fnamemodify(workspace_dir, ':t'),
          }
        end,
      },
    }
  end,
}
