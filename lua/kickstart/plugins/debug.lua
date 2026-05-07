-- debug.lua

local pack = require 'custom.pack'

local specs = {
  pack.gh 'igorlfs/nvim-dap-view',
  pack.gh 'theHamsta/nvim-dap-virtual-text',
  pack.gh 'mfussenegger/nvim-dap',
}

local function setup()
  local dap = require 'dap'
  local dapview = require 'dap-view'

  dapview.setup {
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    ---@diagnostic disable-next-line: missing-fields
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  require('nvim-dap-virtual-text').setup {
    commented = true,
    virt_text_pos = 'inline',
  }

  vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
  vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
  local breakpoint_icons = vim.g.have_nerd_font and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
  for type, icon in pairs(breakpoint_icons) do
    local tp = 'Dap' .. type
    local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
  end

  dap.listeners.after.event_initialized['dapview_config'] = function() vim.cmd 'DapViewOpen' end
  dap.listeners.before.event_terminated['dapview_config'] = function() vim.cmd 'DapViewClose' end
  dap.listeners.before.event_exited['dapview_config'] = function() vim.cmd 'DapViewClose' end

  for _, adapter in pairs { 'node', 'chrome' } do
    local pwa_adapter = 'pwa-' .. adapter

    dap.adapters[pwa_adapter] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'js-debug-adapter',
        args = { '${port}' },
      },
      enrich_config = function(config, on_config)
        config.type = pwa_adapter
        on_config(config)
      end,
    }

    dap.adapters[adapter] = dap.adapters[pwa_adapter]
  end
end

local load = pack.lazy('nvim-dap', specs, setup)

pack.keymaps({
  { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
  { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
  { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
  { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
  { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
  { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint' },
  {
    '<F7>',
    function() vim.cmd 'DapViewToggle' end,
    desc = 'Debug: See last session result.',
  },
}, load)
