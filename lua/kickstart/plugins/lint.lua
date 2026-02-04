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
        markdown = { 'markdownlint' },
        -- Note: JavaScript/TypeScript linters are dynamically selected based on config files
        -- See get_linter_for_buffer() below for selection logic:
        -- - eslint_d: if .eslintrc.* or package.json with eslintConfig exists
        -- - oxlint: if .oxlintrc.json exists
        -- - oxlint_typeaware: fallback if no config found
      }

      -- Config file markers for different linters
      local eslint_configs = {
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json',
        'eslint.config.js',
        'eslint.config.mjs',
        'eslint.config.cjs',
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

        -- Check for ESLint config
        if next(vim.fs.find(eslint_configs, { path = bufpath, upward = true })) then
          return 'eslint_d'
        end

        -- Check for oxlint config
        if next(vim.fs.find(oxlint_configs, { path = bufpath, upward = true })) then
          return 'oxlint'
        end

        -- Check package.json for eslintConfig
        local package_json = vim.fs.find('package.json', { path = bufpath, upward = true })[1]
        if package_json then
          local ok, content = pcall(vim.fn.readfile, package_json)
          if ok then
            local package_str = table.concat(content, '\n')
            if package_str:match('"eslintConfig"') then
              return 'eslint_d'
            end
          end
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
