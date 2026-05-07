--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

vim.o.termguicolors = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true

vim.opt.cmdheight = 2

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.conceallevel = 2

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.api.nvim_create_user_command('LspLog', function() vim.cmd.edit(vim.lsp.get_log_path()) end, { desc = 'Open the LSP log file' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Custom line number colors (Dracula dark_fg grey with green cursor line)
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Custom line number colors',
  group = vim.api.nvim_create_augroup('custom-line-numbers', { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#CECFCC' })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ff79c6', bold = true })
  end,
})

-- Reset conceallevel for JSON files (concealing breaks readability)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'json', 'jsonc' },
  callback = function() vim.opt_local.conceallevel = 0 end,
})

-- Disable mini.trailspace on snacks dashboard. mini.trailspace leaves a
-- window-local matchadd from the initial buffer, and snacks suppresses events
-- (ei="all") when switching to the dashboard buffer so it never gets cleared.
vim.api.nvim_create_autocmd('User', {
  pattern = 'SnacksDashboardOpened',
  callback = function()
    vim.b.minitrailspace_disable = true
    if _G.MiniTrailspace then _G.MiniTrailspace.unhighlight() end
  end,
})

local topgrade = require 'custom.topgrade'
vim.g.is_topgrade_update = topgrade.is_update_session()

if vim.g.is_topgrade_update then topgrade.prepare_update_session() end

-- [[ Configure and install plugins ]]
--    See `:help vim.pack` for Neovim's built-in package manager.
local pack = require 'custom.pack'
local gh = pack.gh

vim.api.nvim_create_autocmd('PackChanged', {
  callback = pack.run_build,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function() vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' }) end)
  end,
})

require 'custom.plugins.dracula'
require 'custom.plugins.nvim-material-icon'
require 'custom.plugins.colorful-menu'

pack.eager({ gh 'NMAC427/guess-indent.nvim' }, function() require('guess-indent').setup {} end)

pack.on_event(
  'VimEnter',
  'which-key.nvim',
  { gh 'folke/which-key.nvim' },
  function()
    require('which-key').setup {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]est' },
        { '<leader>u', group = '[U]I/Toggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
        { 'a', group = 'Around textobject', mode = { 'x', 'o' } },
        { 'aF', desc = 'Around function definition', mode = { 'x', 'o' } },
        { 'aC', desc = 'Around class definition', mode = { 'x', 'o' } },
        { 'ao', desc = 'Around block/loop/conditional', mode = { 'x', 'o' } },
        { 'i', group = 'Inside textobject', mode = { 'x', 'o' } },
        { 'iF', desc = 'Inside function definition', mode = { 'x', 'o' } },
        { 'iC', desc = 'Inside class definition', mode = { 'x', 'o' } },
        { 'io', desc = 'Inside block/loop/conditional', mode = { 'x', 'o' } },
      },
    }
  end
)

-- LSP Plugins
pack.eager({ gh 'neovim/nvim-lspconfig' }, function()
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim, outside this config.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end

      if client and client:supports_method('textDocument/codeLens', event.buf) then
        vim.lsp.codelens.enable(false, { bufnr = event.buf })
        map('<leader>lc', vim.lsp.codelens.run, 'Run CodeLens Action')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They must be installed outside this config.
  --  See `:help lsp-config` for information about keys and how to configure
  -- Apply blink.cmp capabilities to all LSP servers
  pack.build('LuaSnip', function(data)
    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
    vim.system({ 'make', 'install_jsregexp' }, { cwd = data.path })
  end)

  pack.eager({
    { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2' },
    { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
    gh 'folke/lazydev.nvim',
  }, function()
    require('luasnip').setup {}
    require('lazydev').setup {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    }
  end)

  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  })

  -- Resolve Vue language server path for @vue/typescript-plugin (nix-aware)
  local vue_ts_plugin_path
  do
    local vue_ls_bin = vim.fn.exepath 'vue-language-server'
    if vue_ls_bin ~= '' then
      local resolved = vim.fn.resolve(vue_ls_bin)
      local pkg_root = vim.fn.fnamemodify(resolved, ':h:h')
      vue_ts_plugin_path = pkg_root .. '/lib/language-tools/packages/language-server'
    end
  end

  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- TypeScript/JavaScript handled by vtsls (see vtsls entry below)
    vtsls = {
      filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
      settings = {
        vtsls = {
          autoUseWorkspaceTsdk = true,
          tsserver = {
            globalPlugins = vue_ts_plugin_path and {
              {
                name = '@vue/typescript-plugin',
                location = vue_ts_plugin_path,
                languages = { 'vue' },
                configNamespace = 'typescript',
              },
            } or {},
          },
        },
        typescript = {
          tsserver = {
            maxTsServerMemory = 8192,
            nodePath = vim.fn.exepath 'node',
          },
          inlayHints = {
            parameterNames = { enabled = 'all' },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
          updateImportsOnFileMove = { enabled = 'always' },
        },
        javascript = {
          inlayHints = {
            parameterNames = { enabled = 'all' },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
          updateImportsOnFileMove = { enabled = 'always' },
        },
      },
    },
    vue_ls = {},
    dockerls = {
      -- turn telemetry off from the very first packet
      init_options = { telemetry = 'off' },

      -- belt-and-braces: stay opted-out if the client later reloads settings
      settings = {
        ['docker.lsp'] = { telemetry = 'off' },
      },
    },
    emmylua_ls = {},
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    -- ts_ls = {},
  }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end)

pack.eager({
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2' },
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
  gh 'folke/lazydev.nvim',
}, function()
  require('luasnip').setup {}
  require('lazydev').setup {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  }

  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      preset = 'super-tab',

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
      list = { selection = { preselect = true, auto_insert = false } },
      ghost_text = { enabled = true },
      menu = {
        draw = {
          columns = { { 'kind_icon' }, { 'label', gap = 1 } },
          components = {
            label = {
              text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
              highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
            },
          },
        },
      },
    },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = 'prefer_rust' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end)

-- Highlight todo, notes, etc in comments
pack.eager({
  gh 'nvim-lua/plenary.nvim',
  gh 'folke/todo-comments.nvim',
}, function() require('todo-comments').setup { signs = false } end)

pack.eager({ gh 'nvim-mini/mini.nvim' }, function()
  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside next [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  local spec_treesitter = require('mini.ai').gen_spec.treesitter
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
    custom_textobjects = {
      F = spec_treesitter { a = '@function.outer', i = '@function.inner' },
      C = spec_treesitter { a = '@class.outer', i = '@class.inner' },
      o = spec_treesitter {
        a = { '@conditional.outer', '@loop.outer', '@block.outer' },
        i = { '@conditional.inner', '@loop.inner', '@block.inner' },
      },
    },
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  require('mini.surround').setup()

  require('mini.operators').setup()

  require('mini.align').setup()

  require('mini.bracketed').setup()

  require('mini.cursorword').setup()

  require('mini.misc').setup()

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

  require('mini.git').setup()

  require('mini.icons').setup()

  require('mini.visits').setup()

  require('mini.map').setup()

  require('mini.trailspace').setup()
  -- ... and there is more!
  --  Check out: https://github.com/nvim-mini/mini.nvim
end)

pack.build('nvim-treesitter', ':TSUpdate')
pack.eager({ { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }, function()
  local nvim_treesitter = require 'nvim-treesitter'
  local available_parsers = nvim_treesitter.get_available()
  local warned_languages = {}
  local ignored_filetypes = {
    noice = true,
    snacks_notif = true,
    snacks_notif_history = true,
    ['blink-cmp-menu'] = true,
    ['blink-cmp-documentation'] = true,
    ['blink-cmp-signature'] = true,
  }

  local function managed_parser_path(language) return vim.fs.joinpath(vim.fn.stdpath 'data', 'site', 'parser', language .. '.so') end

  local function warn_missing_parser(language, message)
    if warned_languages[language] then return end
    warned_languages[language] = true
    vim.notify(message, vim.log.levels.WARN, { title = 'Tree-sitter' })
  end

  ---@param buf integer
  ---@param language string
  ---@param parser_path string
  local function treesitter_try_attach(buf, language, parser_path)
    if not vim.api.nvim_buf_is_valid(buf) then return end

    local added, err = vim.treesitter.language.add(language, { path = parser_path })
    if not added then
      warn_missing_parser(language, string.format('Failed to load %s parser from %s: %s', language, parser_path, err or 'unknown error'))
      return
    end

    -- enables syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- enables treesitter based folds
    -- for more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- enables treesitter based indentation
    if has_indent_query then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      -- UI buffers manage their own rendering and should not trigger parser installs or warnings.
      if ignored_filetypes[filetype] then return end

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local parser_path = managed_parser_path(language)

      if vim.uv.fs_stat(parser_path) then
        treesitter_try_attach(buf, language, parser_path)
        return
      end

      if not vim.tbl_contains(available_parsers, language) then
        warn_missing_parser(language, string.format('No nvim-treesitter parser is available for %s.', language))
        return
      end

      -- Install into stdpath('data')/site so nvim-treesitter owns both parser and queries.
      nvim_treesitter.install(language):await(function(err, success)
        if err or not success then
          warn_missing_parser(language, string.format('Failed to install %s via nvim-treesitter.', language))
          return
        end

        local installed_parser_path = managed_parser_path(language)
        if not vim.uv.fs_stat(installed_parser_path) then
          warn_missing_parser(language, string.format('Installed %s, but no parser was found at %s.', language, installed_parser_path))
          return
        end

        treesitter_try_attach(buf, language, installed_parser_path)
      end)
    end,
  })
end)

require 'custom.plugins.snacks'
require 'custom.plugins.trouble'
require('custom.git_hunks').setup()

require 'kickstart.plugins.debug'
require 'kickstart.plugins.lint'

require 'custom.plugins.aerial'
require 'custom.plugins.amp'
dofile(vim.fs.joinpath(vim.fn.stdpath 'config', 'lua/custom/plugins/blink.indent.lua'))
dofile(vim.fs.joinpath(vim.fn.stdpath 'config', 'lua/custom/plugins/blink.pairs.lua'))
require 'custom.plugins.codecompanion'
require 'custom.plugins.conform'
require 'custom.plugins.dadbod-grip'
require 'custom.plugins.dropbar'
require 'custom.plugins.eslint'
require 'custom.plugins.grug-far'
require 'custom.plugins.hardtime'
require 'custom.plugins.helpview'
require 'custom.plugins.image'
require 'custom.plugins.lensline'
require 'custom.plugins.lualine'
require 'custom.plugins.markview'
require 'custom.plugins.neoscroll'
require 'custom.plugins.neotest'
require 'custom.plugins.noice'
require 'custom.plugins.obsidian'
require 'custom.plugins.octo'
require 'custom.plugins.origami'
require 'custom.plugins.otter'
require 'custom.plugins.pretty-ts-errors'
require 'custom.plugins.rulebook'
require 'custom.plugins.smart-motion'
require 'custom.plugins.splitjoin'
require 'custom.plugins.todo-comments'
require 'custom.plugins.treejs'
require 'custom.plugins.treesitter-textobjects'
require 'custom.plugins.treewalker'
require 'custom.plugins.ts-comments'
require 'custom.plugins.ts-error-translator'
require 'custom.plugins.ts-expand-hover'
require 'custom.plugins.typescript-tools'
require 'custom.plugins.uv'
require 'custom.plugins.yazi'
require 'custom.plugins.yazelix'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
