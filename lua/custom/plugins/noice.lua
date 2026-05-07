local pack = require 'custom.pack'

pack.on_very_lazy('noice.nvim', {
  pack.gh 'MunifTanjim/nui.nvim',
  pack.gh 'folke/noice.nvim',
}, function()
  require('noice').setup {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = false,
    },
  }
end)
