local pack = require 'custom.pack'

pack.on_ft({ 'typescript', 'typescriptreact' }, 'ts-expand-hover.nvim', { pack.gh 'nemanjamalesija/ts-expand-hover.nvim' }, function()
  local ts_expand_hover = require 'ts_expand_hover'

  ts_expand_hover.setup {
    keymaps = { hover = false },
  }

  local map_hover = function(bufnr)
    vim.keymap.set('n', 'K', ts_expand_hover.hover, {
      buffer = bufnr,
      desc = 'TypeScript expandable hover',
    })
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('ts-expand-hover-keymaps', { clear = true }),
    pattern = { 'typescript', 'typescriptreact' },
    callback = function(event) map_hover(event.buf) end,
  })

  map_hover(vim.api.nvim_get_current_buf())
end)
