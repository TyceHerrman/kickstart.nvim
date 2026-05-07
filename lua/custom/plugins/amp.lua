local pack = require 'custom.pack'

pack.eager({ { src = pack.gh 'sourcegraph/amp.nvim', version = 'main' } }, function()
  require('amp').setup {
    -- Topgrade headless runs must not auto-start background services.
    auto_start = not vim.g.is_topgrade_update,
    log_level = 'info',
  }
end)
