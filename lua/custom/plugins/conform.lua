return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    -- Define your formatters
    formatters_by_ft = {
      lua = { 'stylua' },
      markdown = { 'rumdl' },
      python = { 'ruff_format' },  -- Changed from isort + black
      javascript = { 'biome' },     -- Changed from prettier
      typescript = { 'biome' },     -- Add TypeScript
    },
    -- Set default options
    default_format_opts = {
      lsp_format = 'fallback',
    },
    -- Set up format-on-save
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },

      biome = {
        prepend_args = function(self, ctx)
          local has_config = vim.fs.find({
            "biome.json",
            "biome.jsonc",
          }, { upward = true, path = ctx.filename })[1]

          -- Always disable linting since you're using lint.nvim
          local base_args = {
            "--linter-enabled=false",
          }

          if has_config then
            return base_args
          end

          local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = ctx.buf })
          local expandtab = vim.api.nvim_get_option_value("expandtab", { buf = ctx.buf })

          return vim.list_extend(base_args, {
            "--javascript-formatter-indent-width=" .. shiftwidth,
            "--javascript-formatter-indent-style=" .. (expandtab and "space" or "tab"),
          })
        end,
      },

      ruff_format = {
        prepend_args = function(self, ctx)
          local has_config = vim.fs.find({
            "pyproject.toml",
            "ruff.toml",
            ".ruff.toml",
          }, { upward = true, path = ctx.filename })[1]

          if has_config then
            return {}
          end

          local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = ctx.buf })
          local expandtab = vim.api.nvim_get_option_value("expandtab", { buf = ctx.buf })

          return {
            "--config",
            "indent-width=" .. shiftwidth,
            "--config",
            expandtab and "indent-style=space" or "indent-style=tab",
          }
        end,
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
