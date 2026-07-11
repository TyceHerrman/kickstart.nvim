local pack = require 'custom.pack'

pack.build('telescope-fzf-native.nvim', 'make')
pack.eager({
  pack.gh 'nvim-telescope/telescope-fzf-native.nvim',
  pack.gh 'Bekaboo/dropbar.nvim',
}, function()
  -- Upstream mini.icons tracking:
  --   Issue: https://github.com/Bekaboo/dropbar.nvim/issues/179
  --   PRs: https://github.com/Bekaboo/dropbar.nvim/pull/186
  --        https://github.com/Bekaboo/dropbar.nvim/pull/188
  local function mini_icon(category, path)
    local icon, hl = require('mini.icons').get(category, path)
    return icon .. ' ', hl
  end

  require('dropbar').setup {
    icons = {
      kinds = {
        dir_icon = function(path) return mini_icon('directory', path) end,
        file_icon = function(path) return mini_icon('file', path) end,
      },
    },
  }

  local dropbar_api = require 'dropbar.api'
  vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
  vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
  vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
end)
