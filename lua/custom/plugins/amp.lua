return {
  'sourcegraph/amp.nvim',
  branch = 'main',
  lazy = false,
  opts = {
    -- Topgrade headless runs must not auto-start background services.
    auto_start = not vim.g.is_topgrade_update,
    log_level = 'info',
  },
}
