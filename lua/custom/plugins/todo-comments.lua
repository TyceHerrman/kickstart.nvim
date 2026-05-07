vim.keymap.set('n', '<leader>st', function() Snacks.picker.todo_comments() end, { desc = 'Todo' })

vim.keymap.set('n', '<leader>sT', function() Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' } } end, { desc = 'Todo/Fix/Fixme' })
