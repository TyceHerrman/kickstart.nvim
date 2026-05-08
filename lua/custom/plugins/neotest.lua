local pack = require 'custom.pack'

local specs = {
  pack.gh 'nvim-neotest/nvim-nio',
  -- Upstream plenary tracking:
  --   Issue: https://github.com/nvim-neotest/neotest/issues/502
  pack.gh 'nvim-lua/plenary.nvim',
  pack.gh 'antoinemadec/FixCursorHold.nvim',
  pack.gh 'nvim-treesitter/nvim-treesitter',
  pack.gh 'nvim-neotest/neotest-python',
  pack.gh 'adrigzr/neotest-mocha',
  pack.gh 'nvim-neotest/neotest',
}

local function setup()
  require('neotest').setup {
    adapters = {
      require 'neotest-python' {
        dap = { justMyCode = true },
        args = { '--log-level', 'DEBUG', '--quiet' },
        runner = 'pytest',
      },
      require 'neotest-mocha' {
        command = 'npm test --',
        env = { CI = true },
        cwd = function() return vim.fn.getcwd() end,
      },
    },
    status = {
      virtual_text = true,
    },
    floating = {
      border = 'rounded',
    },
    icons = {
      passed = '✓',
      running = '●',
      failed = '✗',
      skipped = '○',
      unknown = '?',
      running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
    },
  }
end

local load = pack.lazy('neotest', specs, setup)

pack.keymaps({
  { '<leader>tt', function() require('neotest').run.run(vim.fn.expand '%') end, desc = 'Run File' },
  { '<leader>tT', function() require('neotest').run.run(vim.fn.getcwd()) end, desc = 'Run All Test Files' },
  { '<leader>tr', function() require('neotest').run.run() end, desc = 'Run Nearest' },
  { '<leader>tl', function() require('neotest').run.run_last() end, desc = 'Run Last' },
  { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle Summary' },
  { '<leader>to', function() require('neotest').output.open { enter = true, auto_close = true } end, desc = 'Show Output' },
  { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle Output Panel' },
  { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop' },
  { '<leader>tw', function() require('neotest').watch.toggle(vim.fn.expand '%') end, desc = 'Toggle Watch' },
  { '<leader>td', function() require('neotest').run.run { strategy = 'dap' } end, desc = 'Debug Nearest' },
}, load)
