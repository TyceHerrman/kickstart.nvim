local pack = require 'custom.pack'

local specs = { pack.gh 'joryeugene/dadbod-grip.nvim' }
local load = pack.lazy('dadbod-grip.nvim', specs, function()
  require('dadbod-grip').setup { completion = false }

  require('blink.cmp').setup {
    sources = {
      providers = {
        dadbod_grip = { name = 'Grip SQL', module = 'dadbod-grip.completion.blink' },
      },
    },
  }
end)

pack.keymaps({
  { '<leader>db', '<cmd>GripConnect<cr>', desc = 'DB connect' },
  { '<leader>dg', '<cmd>Grip<cr>', desc = 'DB grid' },
  { '<leader>dt', '<cmd>GripTables<cr>', desc = 'DB tables' },
  { '<leader>dq', '<cmd>GripQuery<cr>', desc = 'DB query pad' },
  { '<leader>ds', '<cmd>GripSchema<cr>', desc = 'DB schema' },
  { '<leader>dh', '<cmd>GripHistory<cr>', desc = 'DB history' },
}, load)
