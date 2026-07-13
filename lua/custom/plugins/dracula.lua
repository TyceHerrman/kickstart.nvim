local pack = require 'custom.pack'

pack.eager({ pack.gh 'AndresYague/dracula.nvim' }, function()
  local function apply_helpview_highlights()
    local links = {
      HelpviewPalette0Fg = 'Comment',
      HelpviewPalette1Fg = '@markup.heading.1.markdown',
      HelpviewPalette2Fg = '@markup.heading.2.markdown',
      HelpviewPalette3Fg = '@markup.heading.3.markdown',
      HelpviewPalette4Fg = '@markup.heading.4.markdown',
      HelpviewPalette5Fg = '@markup.heading.5.markdown',
      HelpviewPalette6Fg = '@markup.heading.6.markdown',
      HelpviewCode = 'NormalFloat',
      HelpviewCodeInfo = 'Comment',
      HelpviewInlineCode = '@markup.raw',
      HelpviewTaglink = '@markup.link.vimdoc',
      HelpviewOptionlink = '@markup.link.vimdoc',
      HelpviewKeycode = '@string.special.vimdoc',
      HelpviewArgument = '@variable.parameter.vimdoc',
    }

    for group, link in pairs(links) do
      vim.api.nvim_set_hl(0, group, { link = link })
    end
  end

  vim.o.background = 'dark'
  vim.cmd.colorscheme 'dracula'
  -- Keep Helpview colorscheme-owned while following upstream's local-link guidance.
  apply_helpview_highlights()
end)
