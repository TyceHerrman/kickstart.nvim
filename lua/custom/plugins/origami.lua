local pack = require 'custom.pack'
local origami_config = require 'custom.origami_config'

origami_config.apply_vim_options()

pack.on_very_lazy('nvim-origami', { pack.gh 'chrisgrieser/nvim-origami' }, function() require('origami').setup(origami_config.options) end)
