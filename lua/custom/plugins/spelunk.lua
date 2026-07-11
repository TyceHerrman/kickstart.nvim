local pack = require 'custom.pack'

local specs = { pack.gh 'EvWilson/spelunk.nvim' }

local function setup()
  require('spelunk').setup {
    enable_persist = true,
    persist_by_git_branch = true,
    fuzzy_search_provider = 'snacks',
    enable_status_col_display = false,
    base_mappings = {
      toggle = 'NONE',
      add = 'NONE',
      delete = 'NONE',
      next_bookmark = 'NONE',
      prev_bookmark = 'NONE',
      search_bookmarks = 'NONE',
      search_current_bookmarks = 'NONE',
      search_stacks = 'NONE',
      change_line = 'NONE',
    },
  }
end

local load = pack.lazy('spelunk.nvim', specs, setup)

local function call(method, ...)
  local args = { ... }
  return function() return require('spelunk')[method](table.unpack(args)) end
end

pack.keymaps({
  { '<leader>mst', call 'toggle_window', desc = 'Spelunk toggle UI' },
  { '<leader>msa', call 'add_bookmark', desc = 'Spelunk add bookmark' },
  { '<leader>msd', call 'delete_bookmark', desc = 'Spelunk delete bookmark' },
  { '<leader>msn', call('select_and_goto_bookmark', 1), desc = 'Spelunk next bookmark' },
  { '<leader>msp', call('select_and_goto_bookmark', -1), desc = 'Spelunk previous bookmark' },
  { '<leader>msf', call 'search_marks', desc = 'Spelunk search bookmarks' },
  { '<leader>msc', call 'search_current_marks', desc = 'Spelunk search current stack' },
  { '<leader>mss', call 'search_stacks', desc = 'Spelunk search stacks' },
  { '<leader>msN', call 'new_stack', desc = 'Spelunk new stack' },
  { '<leader>msE', call 'edit_current_stack', desc = 'Spelunk edit stack' },
  { '<leader>msq', call 'qf_current_marks', desc = 'Spelunk quickfix current stack' },
  { '<leader>msQ', call 'qf_all_marks', desc = 'Spelunk quickfix all stacks' },
}, load)
