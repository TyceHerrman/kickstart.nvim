local pack = require 'custom.pack'

local function smart_split_join()
  local captures = vim.treesitter.get_captures_at_cursor(0)
  for _, capture in ipairs(captures) do
    if capture == 'string' or capture == 'comment' then return require('mini.splitjoin').toggle() end
  end

  local ok, treesj = pcall(require, 'treesj')
  if ok then
    local line_before = vim.api.nvim_get_current_line()
    local cursor_before = vim.api.nvim_win_get_cursor(0)
    local success = pcall(treesj.toggle)
    local line_after = vim.api.nvim_get_current_line()
    local cursor_after = vim.api.nvim_win_get_cursor(0)

    if success and (line_before ~= line_after or cursor_before[1] ~= cursor_after[1] or cursor_before[2] ~= cursor_after[2]) then return end
  end

  require('mini.splitjoin').toggle()
end

local function setup() require('mini.splitjoin').setup() end

local specs = { pack.gh 'echasnovski/mini.splitjoin' }
pack.keymaps({ { 'gS', smart_split_join, desc = 'Smart split/join' } }, pack.lazy('mini.splitjoin', specs, setup))
