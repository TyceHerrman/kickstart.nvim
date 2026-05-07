local pack = require 'custom.pack'

if vim.fn.has 'nvim-0.10.0' == 1 then
  pack.on_very_lazy('ts-comments.nvim', { pack.gh 'folke/ts-comments.nvim' }, function() require('ts-comments').setup {} end)
end
