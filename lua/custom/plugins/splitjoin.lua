return {
  'echasnovski/mini.splitjoin',
  version = false,
  keys = {
    { 'gS', desc = 'Smart split/join' },
  },
  config = function()
    require('mini.splitjoin').setup()

    -- Smart split/join function
    local function smart_split_join()
      -- Check if we're in a comment or string using treesitter captures
      local captures = vim.treesitter.get_captures_at_cursor(0)
      for _, capture in ipairs(captures) do
        if capture == 'string' or capture == 'comment' then
          return require('mini.splitjoin').toggle()
        end
      end

      -- Try treesj for everything else
      local ok, treesj = pcall(require, 'treesj')
      if ok then
        -- Capture state before treesj attempt
        local line_before = vim.api.nvim_get_current_line()
        local cursor_before = vim.api.nvim_win_get_cursor(0)

        -- Attempt treesj (wrapped in pcall to catch any errors)
        local success = pcall(treesj.toggle)

        -- Check if anything changed
        local line_after = vim.api.nvim_get_current_line()
        local cursor_after = vim.api.nvim_win_get_cursor(0)

        if success and (line_before ~= line_after or cursor_before[1] ~= cursor_after[1] or cursor_before[2] ~= cursor_after[2]) then
          return -- treesj successfully made changes
        end
      end

      -- Fall back to mini.splitjoin
      require('mini.splitjoin').toggle()
    end

    vim.keymap.set('n', 'gS', smart_split_join, { desc = 'Smart split/join' })
  end,
}
