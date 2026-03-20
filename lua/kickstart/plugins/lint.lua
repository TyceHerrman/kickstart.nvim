-- Linting

---@module 'lazy'
---@type LazySpec
return {
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Create oxlint with type-aware support (for projects without config)
      lint.linters.oxlint_typeaware = vim.tbl_extend('force', lint.linters.oxlint, {
        args = { '--format', 'github', '--type-aware' },
      })

      -- Define linters for each filetype
      lint.linters_by_ft = {
        markdown = { 'rumdl' },
        -- Note: JavaScript/TypeScript linters are dynamically selected based on config files
        -- See get_linter_for_buffer() below for selection logic:
        -- - oxlint: if .oxlintrc.json exists
        -- - oxlint_typeaware: fallback if no config found
      }

      local oxlint_configs = {
        '.oxlintrc.json',
      }

      -- Detect which linter to use based on config presence
      local function get_linter_for_buffer()
        local bufpath = vim.api.nvim_buf_get_name(0)
        if bufpath == '' then
          return nil
        end

        -- Check for oxlint config
        if next(vim.fs.find(oxlint_configs, { path = bufpath, upward = true })) then
          return 'oxlint'
        end

        -- No config found, use oxlint with type-aware defaults
        return 'oxlint_typeaware'
      end

      -- Create autocommand with dynamic linter selection
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if not vim.bo.modifiable then
            return
          end

          local ft = vim.bo.filetype
          local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

          -- For JS/TS/Vue files, use dynamic linter selection
          if vim.tbl_contains(js_filetypes, ft) then
            local linter = get_linter_for_buffer()
            if linter then
              lint.try_lint(linter)
            end
          else
            -- For other filetypes, use default behavior
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
