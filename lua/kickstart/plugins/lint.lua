-- Linting

local pack = require 'custom.pack'

pack.on_event({ 'BufReadPre', 'BufNewFile' }, 'nvim-lint', { pack.gh 'mfussenegger/nvim-lint' }, function()
  local lint = require 'lint'
  local nvim_config_root = vim.fn.stdpath 'config'

  lint.linters.oxlint_typeaware = vim.tbl_extend('force', lint.linters.oxlint, {
    args = { '--format', 'github', '--type-aware' },
  })

  -- Workspace-level checker. Run manually so it doesn't fire on every Lua buffer event.
  lint.linters.emmylua_check = {
    cmd = 'emmylua_check',
    stdin = false,
    append_fname = false,
    args = { '-f', 'json', '.' },
    stream = 'stdout',
    ignore_exitcode = true,
    cwd = nvim_config_root,
    parser = function(output, bufnr, linter_cwd)
      local diagnostics = {}
      if output == '' then return diagnostics end

      local ok, decoded = pcall(vim.json.decode, output)
      if not ok or type(decoded) ~= 'table' then return diagnostics end

      local bufname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
      local root = linter_cwd or nvim_config_root
      local severity_map = {
        [1] = vim.diagnostic.severity.ERROR,
        [2] = vim.diagnostic.severity.WARN,
        [3] = vim.diagnostic.severity.INFO,
        [4] = vim.diagnostic.severity.HINT,
      }

      for _, file_entry in ipairs(decoded) do
        local filepath = file_entry.file
        if type(filepath) == 'string' and filepath ~= '' then
          if not vim.startswith(filepath, '/') then filepath = root .. '/' .. filepath:gsub('^%./', '') end

          if vim.fs.normalize(filepath) == bufname then
            for _, diag in ipairs(file_entry.diagnostics or {}) do
              local range = diag.range or {}
              local start = range.start or {}
              local finish = range['end'] or {}

              table.insert(diagnostics, {
                lnum = start.line or 0,
                col = start.character or 0,
                end_lnum = finish.line,
                end_col = finish.character,
                severity = severity_map[diag.severity] or vim.diagnostic.severity.WARN,
                message = diag.message or '',
                source = 'emmylua_check',
              })
            end
          end
        end
      end

      return diagnostics
    end,
  }

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
      if ft == 'lua' then return end

      local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

      if vim.tbl_contains(js_filetypes, ft) then
        local linter = get_linter_for_buffer()
        if linter then lint.try_lint(linter) end
      else
        lint.try_lint()
      end
    end,
  })

  vim.keymap.set('n', '<leader>le', function() lint.try_lint 'emmylua_check' end, {
    desc = '[L]int [E]mmyLua check',
  })
end)
