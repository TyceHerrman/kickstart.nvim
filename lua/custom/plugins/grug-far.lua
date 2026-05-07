local pack = require 'custom.pack'

pack.eager({ pack.gh 'MagicDuck/grug-far.nvim' }, function()
  require('grug-far').setup {}

  local grug = require 'grug-far'

  vim.keymap.set('n', '<leader>sw', function() grug.open { prefills = { search = vim.fn.expand '<cword>' } } end)

  vim.keymap.set('v', '<leader>sw', function() grug.with_visual_selection() end)

  vim.keymap.set('n', '<leader>sf', function() grug.open { prefills = { paths = vim.fn.expand '%' } } end)

  vim.keymap.set('n', '<leader>st', function() grug.toggle_instance { instanceName = 'far', staticTitle = 'Find and Replace' } end)

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('grug-far-custom', { clear = true }),
    pattern = { 'grug-far' },
    callback = function()
      vim.keymap.set('n', '<localleader>w', function()
        local state = unpack(grug.get_instance(0):toggle_flags { '--fixed-strings' })
        vim.notify('Fixed strings: ' .. (state and 'ON' or 'OFF'))
      end, { buffer = true })
    end,
  })
end)
