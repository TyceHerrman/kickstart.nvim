local pack = require 'custom.pack'

local codelens_cache = {}

local function get_codelens_clients(bufnr)
  return vim.tbl_filter(function(client) return client:supports_method('textDocument/codeLens', bufnr) end, vim.lsp.get_clients { bufnr = bufnr })
end

local function request_codelenses(bufnr, callback)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    callback {}
    return
  end

  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local cached = codelens_cache[bufnr]

  if cached and cached.changedtick == changedtick and cached.lenses then
    callback(cached.lenses)
    return
  end

  if cached and cached.changedtick == changedtick and cached.pending then
    table.insert(cached.callbacks, callback)
    return
  end

  local clients = get_codelens_clients(bufnr)
  if #clients == 0 then
    codelens_cache[bufnr] = { changedtick = changedtick, lenses = {} }
    callback {}
    return
  end

  codelens_cache[bufnr] = {
    changedtick = changedtick,
    pending = true,
    callbacks = { callback },
  }

  local remaining = #clients
  local lenses = {}
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  local function finish()
    remaining = remaining - 1
    if remaining > 0 then return end

    local entry = codelens_cache[bufnr]
    local callbacks = entry and entry.callbacks or {}
    codelens_cache[bufnr] = {
      changedtick = changedtick,
      lenses = lenses,
    }

    for _, cb in ipairs(callbacks) do
      cb(lenses)
    end
  end

  for _, client in ipairs(clients) do
    client:request('textDocument/codeLens', params, function(err, result)
      if not err and result then vim.list_extend(lenses, result) end
      finish()
    end, bufnr)
  end
end

local function codelens_actions_provider()
  return {
    name = 'codelens_actions',
    enabled = true,
    event = { 'LspAttach', 'BufWritePost' },
    highlight = 'Function',
    icon = '󰌵 ',
    show_titles = true,
    handler = function(bufnr, func_info, provider_config, callback)
      request_codelenses(bufnr, function(lenses)
        local line = func_info.line
        local titles = {}
        local count = 0

        for _, lens in ipairs(lenses) do
          local lens_line = lens.range and lens.range.start and (lens.range.start.line + 1)
          if lens_line == line then
            count = count + 1
            if lens.command and lens.command.title then table.insert(titles, lens.command.title) end
          end
        end

        if count == 0 then
          callback(nil)
          return
        end

        local label
        if provider_config.show_titles ~= false and count == 1 and titles[1] then
          label = titles[1]
        else
          label = count == 1 and '1 action' or string.format('%d actions', count)
        end

        callback {
          line = line,
          text = (provider_config.icon or '') .. label,
        }
      end)
    end,
  }
end

local specs = { { src = pack.gh 'oribarilan/lensline.nvim', version = 'v2.1.0' } }

local function setup()
  require('lensline').setup {
    profiles = {
      {
        name = 'default',
        providers = {
          {
            name = 'usages',
            enabled = true,
            include = { 'refs' },
            breakdown = false,
            show_zero = false,
          },
          {
            name = 'last_author',
            enabled = true,
            highlight = 'String',
          },
          codelens_actions_provider(),
          {
            name = 'diagnostics',
            enabled = true,
            min_level = 'WARN',
            highlight = 'DiagnosticWarn',
          },
          {
            name = 'complexity',
            enabled = false,
          },
        },
        style = {
          placement = 'inline',
          render = 'focused',
          prefix = '',
          separator = ' | ',
          highlight = 'Comment',
          use_nerdfont = true,
        },
      },
      {
        name = 'review',
        providers = {
          {
            name = 'usages',
            enabled = true,
            include = { 'refs', 'defs', 'impls' },
            breakdown = true,
            show_zero = false,
          },
          {
            name = 'last_author',
            enabled = true,
            highlight = 'String',
          },
          codelens_actions_provider(),
          {
            name = 'diagnostics',
            enabled = true,
            min_level = 'WARN',
            highlight = 'DiagnosticWarn',
          },
          {
            name = 'complexity',
            enabled = true,
            min_level = 'L',
            highlight = 'Type',
          },
        },
        style = {
          placement = 'above',
          render = 'focused',
          prefix = '┃ ',
          separator = ' • ',
          highlight = 'Comment',
          use_nerdfont = true,
        },
      },
    },
    limits = {
      exclude_gitignored = true,
      max_lines = 1000,
      max_lenses = 70,
    },
    debounce_ms = 500,
    focused_debounce_ms = 150,
    silence_lsp = false,
    debug_mode = false,
  }
end

local load = pack.lazy('lensline.nvim', specs, setup)

pack.on_event('LspAttach', 'lensline.nvim', specs, setup)
pack.on_event('BufWritePost', 'lensline.nvim', specs, setup)
pack.keymaps({
  {
    '<leader>uv',
    function() require('lensline').toggle_view() end,
    desc = 'Toggle Lensline view',
  },
  {
    '<leader>uE',
    function() require('lensline').toggle_engine() end,
    desc = 'Toggle Lensline engine',
  },
  {
    '<leader>up',
    '<cmd>LenslineProfile<CR>',
    desc = 'Cycle Lensline profile',
  },
}, load)
