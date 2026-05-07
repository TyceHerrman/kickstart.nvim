local pack = require 'custom.pack'

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local function setup()
  require('conform').setup {
    notify_on_error = false,
    formatters_by_ft = {
      lua = { 'stylua' },
      markdown = { 'rumdl' },
      python = { 'ruff_format' },
      javascript = { 'biome' },
      typescript = { 'biome' },
    },
    default_format_opts = {
      lsp_format = 'fallback',
    },
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then return nil end

      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },
      biome = {
        prepend_args = function(_, ctx)
          local has_config = vim.fs.find({
            'biome.json',
            'biome.jsonc',
          }, { upward = true, path = ctx.filename })[1]

          local base_args = {
            '--linter-enabled=false',
          }

          if has_config then return base_args end

          local shiftwidth = vim.api.nvim_get_option_value('shiftwidth', { buf = ctx.buf })
          local expandtab = vim.api.nvim_get_option_value('expandtab', { buf = ctx.buf })

          return vim.list_extend(base_args, {
            '--javascript-formatter-indent-width=' .. shiftwidth,
            '--javascript-formatter-indent-style=' .. (expandtab and 'space' or 'tab'),
          })
        end,
      },
      ruff_format = {
        prepend_args = function(_, ctx)
          local has_config = vim.fs.find({
            'pyproject.toml',
            'ruff.toml',
            '.ruff.toml',
          }, { upward = true, path = ctx.filename })[1]

          if has_config then return {} end

          local shiftwidth = vim.api.nvim_get_option_value('shiftwidth', { buf = ctx.buf })
          local expandtab = vim.api.nvim_get_option_value('expandtab', { buf = ctx.buf })

          return {
            '--config',
            'indent-width=' .. shiftwidth,
            '--config',
            expandtab and 'indent-style=space' or 'indent-style=tab',
          }
        end,
      },
    },
  }
end

local specs = { pack.gh 'stevearc/conform.nvim' }
local load = pack.lazy('conform.nvim', specs, setup)

pack.on_event('BufWritePre', 'conform.nvim', specs, setup)
pack.on_cmd('ConformInfo', 'conform.nvim', specs, setup)
pack.keymaps({
  {
    '<leader>f',
    function() require('conform').format { async = true, lsp_format = 'fallback' } end,
    mode = '',
    desc = '[F]ormat buffer',
  },
}, load)
