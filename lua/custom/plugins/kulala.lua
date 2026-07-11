local pack = require 'custom.pack'

local specs = { pack.gh 'mistweaverco/kulala.nvim' }

pack.build('kulala.nvim', 'git submodule update --init --recursive')

local function setup()
  require('kulala').setup {
    global_keymaps = false,
    global_keymaps_prefix = '<leader>R',
    kulala_keymaps_prefix = '',
  }
end

local load = pack.lazy('kulala.nvim', specs, setup)

pack.on_ft({ 'http', 'rest' }, 'kulala.nvim', specs, setup)

pack.keymaps({
  { '<leader>Rs', function() require('kulala').run() end, mode = { 'n', 'v' }, desc = 'Send request' },
  { '<leader>Ra', function() require('kulala').run_all() end, mode = { 'n', 'v' }, desc = 'Send all requests' },
  { '<leader>Rb', function() require('kulala').scratchpad() end, desc = 'Open scratchpad' },
}, load)
