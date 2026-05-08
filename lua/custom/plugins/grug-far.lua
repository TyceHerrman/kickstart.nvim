local pack = require 'custom.pack'

pack.eager({ pack.gh 'MagicDuck/grug-far.nvim' }, function()
  local grug = require 'grug-far'
  grug.setup({})

  local function map(mode, lhs, rhs, desc, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { desc = 'Grug Far: ' .. desc }, opts or {}))
  end

  map('n', '<leader>sf', function() grug.open({ prefills = { paths = vim.fn.expand '%' } }) end, 'Search current file')
  map('n', '<leader>srw', function() grug.open({ prefills = { search = vim.fn.expand '<cword>' } }) end, 'Search current word')
  map('n', '<leader>srg', function() grug.open({ engine = 'astgrep' }) end, 'Search with ast-grep')
  map('n', '<leader>srt', function() grug.open({ transient = true }) end, 'Open transient search')
  map('v', '<leader>srv', function() grug.with_visual_selection({ prefills = { paths = vim.fn.expand '%' } }) end, 'Search visual selection in current file')
  map({ 'n', 'x' }, '<leader>sri', function() grug.open({ visualSelectionUsage = 'operate-within-range' }) end, 'Search within visual range')
  map({ 'n', 'x' }, '<leader>sra', function() grug.open({ visualSelectionUsage = 'auto-detect' }) end, 'Search with auto-detect range')
  map({ 'n', 'x' }, '<leader>srs', function()
    local search = vim.fn.getreg '/'
    if search and vim.startswith(search, '\\<') and vim.endswith(search, '\\>') then
      search = '\\b' .. search:sub(3, -3) .. '\\b'
    elseif search and vim.startswith(search, '\\V') then
      search = search:sub(3)
    end
    if search == '' then search = nil end
    local inst = grug.open({
      prefills = {
        search = search,
      },
    })
    inst:when_ready(function()
      inst:goto_input('replacement')
    end)
  end, 'Search from last search register')
  map('n', '<leader>sro', function() grug.toggle_instance({ instanceName = 'far', staticTitle = 'Find and Replace' }) end, 'Toggle find/replace panel')

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('grug-far-custom', { clear = true }),
    pattern = { 'grug-far' },
    callback = function()
      map('n', '<localleader>w', function()
        local state = unpack(grug.get_instance(0):toggle_flags({ '--fixed-strings' }))
        vim.notify('Fixed strings: ' .. (state and 'ON' or 'OFF'))
      end, 'Toggle fixed strings', { buffer = true })
    end,
  })
end)
