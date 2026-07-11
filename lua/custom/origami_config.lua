local M = {}

M.foldlevel = 99
M.foldlevelstart = 99
M.options = {}

local fold_keymap_defaults = {
  closeOnlyOnFirstColumn = false,
  scrollLeftOnCaret = false,
}

local function option_or_default(value, default)
  if value == nil then return default end
  return value
end

function M.apply_vim_options()
  vim.opt.foldlevel = M.foldlevel
  vim.opt.foldlevelstart = M.foldlevelstart
end

function M.fold_keymaps()
  local fold_keymaps = M.options.foldKeymaps or {}

  return {
    closeOnlyOnFirstColumn = option_or_default(fold_keymaps.closeOnlyOnFirstColumn, fold_keymap_defaults.closeOnlyOnFirstColumn),
    scrollLeftOnCaret = option_or_default(fold_keymaps.scrollLeftOnCaret, fold_keymap_defaults.scrollLeftOnCaret),
  }
end

return M
