local pack = require 'custom.pack'

pack.eager({
  -- lualine native mini.icons support tracking:
  --   https://github.com/nvim-lualine/lualine.nvim/pull/1428
  pack.gh 'DaikyXendo/nvim-material-icon',
  pack.gh 'nvim-lualine/lualine.nvim',
}, function()
  vim.opt.showmode = false

  local opts = {
    options = {
      theme = 'dracula',
    },
    sections = {
      lualine_c = {
        'filename',
      },
      lualine_x = {
        'encoding',
        'filetype',
      },
    },
  }

  require('lualine').setup(opts)

  vim.api.nvim_create_autocmd('FileType', {
    once = true,
    callback = function()
      if vim.bo.buftype == '' and vim.bo.filetype ~= '' then
        table.insert(opts.sections.lualine_c, {
          'aerial',
          sep = ' > ',
          colored = true,
          cond = function() return vim.bo.buftype == '' and vim.bo.filetype ~= '' end,
        })
        require('lualine').setup(opts)
      end
    end,
  })
end)
