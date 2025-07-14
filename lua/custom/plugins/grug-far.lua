return {
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup {}

    -- Keymaps from cookbook
    local grug = require 'grug-far'

    -- Search word under cursor
    vim.keymap.set('n', '<leader>sw', function()
      grug.open { prefills = { search = vim.fn.expand '<cword>' } }
    end)

    -- Visual selection search
    vim.keymap.set('v', '<leader>sw', function()
      grug.with_visual_selection()
    end)

    -- Search in current file
    vim.keymap.set('n', '<leader>sf', function()
      grug.open { prefills = { paths = vim.fn.expand '%' } }
    end)

    -- Toggle instance (cookbook example)
    vim.keymap.set('n', '<leader>st', function()
      grug.toggle_instance { instanceName = 'far', staticTitle = 'Find and Replace' }
    end)

    -- Custom buffer keymap from cookbook - toggle fixed strings
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
  end,
}
