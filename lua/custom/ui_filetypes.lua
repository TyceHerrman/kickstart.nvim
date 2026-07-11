local M = {}

M.treesitter_ignored = {
  aerial = true,
  ['aerial-nav'] = true,
  ['blink-cmp-documentation'] = true,
  ['blink-cmp-dot-repeat'] = true,
  noice = true,
  ['blink-cmp-menu'] = true,
  ['blink-cmp-signature'] = true,
  codecompanion_cli = true,
  ['conform-info'] = true,
  ['dap-float'] = true,
  ['dap-repl'] = true,
  ['dap-view'] = true,
  ['dap-view-hover'] = true,
  ['dap-view-term'] = true,
  ['dropbar_menu_fzf'] = true,
  dropbar_preview = true,
  ['gitsigns-blame'] = true,
  ['graphql-schema'] = true,
  ['grip-welcome'] = true,
  grip_er = true,
  grip_schema = true,
  image = true,
  image_nvim = true,
  image_nvim_popup = true,
  lazy_backdrop = true,
  minimap = true,
  ['neotest-output-panel'] = true,
  ['neotest-summary'] = true,
  octo_panel = true,
  snacks_dashboard = true,
  snacks_input = true,
  snacks_layout_box = true,
  snacks_notif = true,
  snacks_notif_history = true,
  snacks_picker_input = true,
  snacks_picker_list = true,
  snacks_picker_preview = true,
  snacks_terminal = true,
  snacks_win_backdrop = true,
  snacks_win_help = true,
  text = true,
  trouble = true,
  wk = true,
  yazi = true,
}

function M.should_skip_treesitter(buf, filetype)
  if not vim.api.nvim_buf_is_valid(buf) then return true end
  if vim.bo[buf].buftype ~= '' then return true end

  return M.treesitter_ignored[filetype or vim.bo[buf].filetype] == true
end

return M
