local pack = require 'custom.pack'

pack.eager({ { src = pack.gh 'sourcegraph/amp.nvim', version = 'main' } }, function()
  require('amp').setup {
    -- Headless runs must not auto-start background services.
    auto_start = #vim.api.nvim_list_uis() > 0,
    log_level = 'info',
  }
end)
