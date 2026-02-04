return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
  config = function()
    require('typescript-tools').setup {
      -- Get capabilities from blink.cmp for autocompletion
      capabilities = require('blink.cmp').get_lsp_capabilities(),

      -- LspAttach autocmd in init.lua will still handle keybindings
      -- No need to duplicate on_attach here

      settings = {
        -- Separate diagnostic server for better performance in large monorepos
        separate_diagnostic_server = true,

        -- Increase memory limit for large TypeScript projects (default is 3072)
        tsserver_max_memory = 8192,

        -- Enable Vue support (replaces vtsls Vue plugin config)
        tsserver_plugins = {
          '@vue/typescript-plugin',
        },

        -- Publish diagnostics on insert mode (can disable if too noisy)
        publish_diagnostic_on = 'insert_leave',

        -- Expose useful TypeScript operations as LSP code actions
        -- Access these with your 'gra' keybinding
        expose_as_code_action = {
          'organize_imports',
          'add_missing_imports',
          'remove_unused',
          'remove_unused_imports',
          'fix_all',
        },

        -- TypeScript server settings
        tsserver_file_preferences = {
          -- Enable inlay hints
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,

          -- Import preferences
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          includeCompletionsWithInsertText = true,

          -- Auto-import preferences
          includeCompletionsWithSnippetText = true,
          includeAutomaticOptionalChainCompletions = true,
        },

        tsserver_format_options = {
          -- Let biome handle formatting, disable tsserver formatting
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
        },

        -- JSX settings for React
        jsx_close_tag = {
          enable = true,
          filetypes = { 'javascriptreact', 'typescriptreact' },
        },
      },
    }
  end,
}
