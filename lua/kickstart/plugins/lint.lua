-- Linting

local pack = require 'custom.pack'

pack.on_event({ 'BufReadPre', 'BufNewFile' }, 'nvim-lint', { pack.gh 'mfussenegger/nvim-lint' }, function()
  local lint = require 'lint'

  lint.linters.oxlint_typeaware = vim.tbl_extend('force', lint.linters.oxlint, {
    args = { '--format', 'github', '--type-aware' },
  })

  lint.linters_by_ft = {
    markdown = { 'rumdl' },
  }

  local oxlint_configs = {
    '.oxlintrc.json',
  }

  local function get_linter_for_buffer()
    local bufpath = vim.api.nvim_buf_get_name(0)
    if bufpath == '' then return nil end

    if next(vim.fs.find(oxlint_configs, { path = bufpath, upward = true })) then return 'oxlint' end

    return 'oxlint_typeaware'
  end

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      if not vim.bo.modifiable then return end

      local ft = vim.bo.filetype
      local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

      if vim.tbl_contains(js_filetypes, ft) then
        local linter = get_linter_for_buffer()
        if linter then lint.try_lint(linter) end
      else
        lint.try_lint()
      end
    end,
  })
end)
