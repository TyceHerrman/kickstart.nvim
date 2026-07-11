local pack = require 'custom.pack'

pack.eager({ pack.gh 'gbprod/yanky.nvim' }, function()
  require('yanky').setup {
    ring = {
      storage = 'shada',
    },
    system_clipboard = {
      sync_with_ring = true,
    },
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 500,
    },
    preserve_cursor_position = {
      enabled = true,
    },
  }

  vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)', { desc = 'Yank text' })
  vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)', { desc = 'Put after' })
  vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)', { desc = 'Put before' })
  vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)', { desc = 'Put after and leave cursor after' })
  vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)', { desc = 'Put before and leave cursor after' })

  vim.keymap.set('n', '<C-n>', '<Plug>(YankyNextEntry)', { desc = 'Next yank history entry' })
  vim.keymap.set('n', '<C-p>', '<Plug>(YankyPreviousEntry)', { desc = 'Previous yank history entry' })

  vim.keymap.set({ 'n', 'x' }, '<leader>sy', function()
    if _G.Snacks and Snacks.picker and Snacks.picker.yanky then
      Snacks.picker.yanky()
    else
      vim.cmd.YankyRingHistory()
    end
  end, { desc = 'Yank History' })
end)
