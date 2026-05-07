local pack = require 'custom.pack'

pack.build('nvim-pretty-ts-errors', 'npm install')
pack.eager { pack.gh 'enochchau/nvim-pretty-ts-errors' }
