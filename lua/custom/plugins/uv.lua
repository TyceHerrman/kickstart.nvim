local pack = require 'custom.pack'

pack.on_ft('python', 'uv.nvim', { pack.gh 'benomahony/uv.nvim' }, function()
  require('uv').setup {
    picker_integration = true,
  }
end)
