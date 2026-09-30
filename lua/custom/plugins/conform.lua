local pack = require 'custom.pack'

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local lua_formatter_markers = {
  stylua = {
    '.stylua.toml',
    'stylua.toml',
    '.styluaignore',
  },
  luafmt = {
    '.luafmt.toml',
    'luafmt.toml',
    '.luafmtignore',
  },
}

local function find_lua_formatter_marker(markers, path) return vim.fs.find(markers, { path = path, upward = true })[1] end

local function select_lua_formatter(bufnr)
  if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local search_path = filename ~= '' and vim.fs.dirname(filename) or vim.uv.cwd()
  local stylua_marker = find_lua_formatter_marker(lua_formatter_markers.stylua, search_path)
  local luafmt_marker = find_lua_formatter_marker(lua_formatter_markers.luafmt, search_path)

  if stylua_marker and luafmt_marker then
    local stylua_root = vim.fs.dirname(stylua_marker)
    local luafmt_root = vim.fs.dirname(luafmt_marker)

    if stylua_root == luafmt_root then
      return nil, ('Lua formatter configuration conflict: both %s and %s are declared in %s'):format(stylua_marker, luafmt_marker, stylua_root)
    end

    if #stylua_root > #luafmt_root then return { name = 'stylua', marker = stylua_marker } end
    return { name = 'luafmt', marker = luafmt_marker }
  end

  if stylua_marker then return { name = 'stylua', marker = stylua_marker } end
  if luafmt_marker then return { name = 'luafmt', marker = luafmt_marker } end
  return { name = 'luafmt' }
end

local function lua_formatters(bufnr)
  local selected = select_lua_formatter(bufnr)
  if not selected then return { lsp_format = 'never' } end
  return { selected.name, lsp_format = 'never' }
end

local function notify_lua_formatter_error(message) vim.notify(message, vim.log.levels.ERROR, { title = 'Conform' }) end

local function format_opts(bufnr, opts)
  if vim.bo[bufnr].filetype ~= 'lua' then return vim.tbl_extend('force', opts or {}, { lsp_format = 'fallback' }) end

  local selected, selection_error = select_lua_formatter(bufnr)
  if not selected then
    notify_lua_formatter_error(selection_error or 'Unable to select a Lua formatter')
    return nil
  end

  local formatter_info = require('conform').get_formatter_info(selected.name, bufnr)
  if not formatter_info.available then
    local source = selected.marker and (' selected by ' .. selected.marker) or ' selected by default'
    notify_lua_formatter_error(("Lua formatter '%s'%s is unavailable: %s"):format(selected.name, source, formatter_info.available_msg or 'unknown reason'))
    return nil
  end

  return vim.tbl_extend('force', opts or {}, {
    formatters = { selected.name },
    lsp_format = 'never',
  })
end

local function setup()
  local conform_util = require 'conform.util'

  require('conform').setup {
    notify_on_error = false,
    formatters_by_ft = {
      lua = lua_formatters,
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

      return format_opts(bufnr, { timeout_ms = 500 })
    end,
    formatters = {
      luafmt = {
        command = 'luafmt',
        args = { '--stdin' },
        stdin = true,
        cwd = conform_util.root_file {
          '.luafmt.toml',
          'luafmt.toml',
        },
      },
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
    function()
      local bufnr = vim.api.nvim_get_current_buf()
      local opts = format_opts(bufnr, { async = true })
      if opts then require('conform').format(opts) end
    end,
    mode = '',
    desc = '[F]ormat buffer',
  },
}, load)
