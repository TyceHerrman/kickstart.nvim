local pack = require 'custom.pack'

pack.eager({ pack.gh 'saghen/blink.indent' }, function() require('blink.indent').setup {} end)
