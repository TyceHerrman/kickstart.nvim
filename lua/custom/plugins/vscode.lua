local pack = require 'custom.pack'
local gh = pack.gh

pack.eager({ gh 'NMAC427/guess-indent.nvim' }, function() require('guess-indent').setup {} end)

pack.eager({ { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }, function() require 'nvim-treesitter' end)

pack.eager({ gh 'nvim-mini/mini.nvim' }, function()
  require('mini.surround').setup()
  require('mini.operators').setup()
  require('mini.align').setup()
  require('mini.ai').setup()
  require('mini.bracketed').setup()
  require('mini.cursorword').setup()
  require('mini.misc').setup()
  require('mini.move').setup()
  require('mini.splitjoin').setup()
  require('mini.icons').setup()
  require('mini.visits').setup()
  require('mini.diff').setup {
    view = {
      style = 'sign',
      signs = { add = '+', change = '~', delete = '_' },
    },
    mappings = {
      apply = '',
      reset = '',
      textobject = '',
      goto_first = '',
      goto_prev = '',
      goto_next = '',
      goto_last = '',
    },
  }

  local hipatterns = require 'mini.hipatterns'
  hipatterns.setup {
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color { style = 'inline' },
    },
  }

  require('mini.trailspace').setup()
end)

local treesj_specs = { gh 'Wansmer/treesj' }
local function setup_treesj()
  require('treesj').setup {
    use_default_keymaps = false,
    check_syntax_error = true,
    max_join_length = 120,
    cursor_behavior = 'hold',
    notify = true,
    dot_repeat = true,
  }
end

local load_treesj = pack.lazy('treesj', treesj_specs, setup_treesj)
pack.on_cmd({ 'TSJToggle', 'TSJSplit', 'TSJJoin' }, 'treesj', treesj_specs, setup_treesj)

local function toggle_treesj()
  load_treesj()
  local ok, treesj = pcall(require, 'treesj')
  if ok then
    treesj.toggle()
    return
  end

  require('mini.splitjoin').toggle()
end

local conform_specs = { gh 'stevearc/conform.nvim' }
local function setup_conform()
  require('conform').setup {
    notify_on_error = false,
    formatters_by_ft = {
      markdown = { 'rumdl' },
      python = { 'ruff_format' },
      javascript = { 'biome' },
      typescript = { 'biome' },
    },
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

local load_conform = pack.lazy('conform.nvim', conform_specs, setup_conform)
pack.on_cmd('ConformInfo', 'conform.nvim', conform_specs, setup_conform)
vim.keymap.set({ 'n', 'x' }, '<leader>f', function()
  load_conform()
  require('conform').format {
    async = true,
    lsp_format = vim.bo.filetype == 'lua' and 'prefer' or 'never',
  }
end, { desc = '[F]ormat buffer' })

pack.eager({ gh 'FluxxField/smart-motion.nvim' }, function()
  require('smart-motion').setup {
    history_max_size = 0,
    presets = {
      words = true,
      lines = true,
      search = true,
      delete = true,
      yank = true,
      change = true,
      paste = true,
      treesitter = true,
      diagnostics = true,
      git = true,
      quickfix = true,
      marks = true,
      misc = true,
    },
  }
  pcall(vim.api.nvim_del_augroup_by_name, 'SmartMotionHistory')
  require('custom.smart_motion_textobjects').setup()
end)

require 'custom.plugins.yanky'
require 'custom.plugins.treewalker'
require 'custom.plugins.ts-comments'
require 'custom.plugins.kulala'
require 'custom.plugins.obsidian'
require('custom.vscode_origami').setup()

vim.keymap.set('n', 'gS', toggle_treesj, { desc = 'Smart split/join' })
