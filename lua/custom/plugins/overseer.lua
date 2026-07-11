local pack = require 'custom.pack'

local specs = { pack.gh 'stevearc/overseer.nvim' }

local function setup()
  local overseer = require 'overseer'

  overseer.setup {
    dap = true,
    task_list = {
      direction = 'bottom',
      max_height = { 20, 0.3 },
      min_height = 8,
    },
    form = {
      border = 'rounded',
    },
    task_win = {
      border = 'rounded',
    },
  }

  -- Overseer's built-in mise provider can discover ~/.config/mise/tasks.toml
  -- from this repo through ~/.config and build tasks with cwd=~. Keep the
  -- built-in provider, but run mise from the active project so global tasks
  -- see the same cwd as `mise run <task>` in the shell.
  -- Upstream issue: https://github.com/stevearc/overseer.nvim/issues/515
  overseer.add_template_hook({ name = '^mise ' }, function(task_defn)
    if vim.tbl_get(task_defn, 'cmd', 1) == 'mise' and vim.tbl_get(task_defn, 'cmd', 2) == 'run' then task_defn.cwd = vim.fn.getcwd() end
  end)
end

pack.eager(specs, setup)

pack.keymaps {
  { '<leader>jr', '<cmd>OverseerRun<cr>', desc = 'Overseer run task' },
  { '<leader>js', '<cmd>OverseerShell<cr>', desc = 'Overseer shell task' },
  { '<leader>jj', '<cmd>OverseerToggle! bottom<cr>', desc = 'Overseer toggle tasks' },
  { '<leader>jo', '<cmd>OverseerOpen! bottom<cr>', desc = 'Overseer open tasks' },
  { '<leader>jc', '<cmd>OverseerClose<cr>', desc = 'Overseer close tasks' },
  { '<leader>ja', '<cmd>OverseerTaskAction<cr>', desc = 'Overseer task action' },
}
