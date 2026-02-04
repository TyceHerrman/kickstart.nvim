return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  opts = {
    options = {
      theme = 'dracula',
    },
    sections = {
    -- this extends the defaults   [oai_citation:1‡GitHub](https://github.com/nvim-lualine/lualine.nvim?utm_source=chatgpt.com)
      lualine_c = {
        'filename',
      },
      lualine_x = {
        'encoding',
        'filetype',
      },
    },
  },
  config = function(_, opts)
    vim.opt.showmode = false

    -- Setup lualine without aerial initially
    require('lualine').setup(opts)

    -- Add aerial to lualine after first real file is opened
    vim.api.nvim_create_autocmd('FileType', {
      once = true,
      callback = function()
        -- Only add if it's a normal file buffer
        if vim.bo.buftype == '' and vim.bo.filetype ~= '' then
          table.insert(opts.sections.lualine_c, {
            'aerial',
            sep = ' > ',
            colored = true,
            cond = function()
              return vim.bo.buftype == '' and vim.bo.filetype ~= ''
            end,
          })
          require('lualine').setup(opts)
        end
      end,
    })
  end,
}
