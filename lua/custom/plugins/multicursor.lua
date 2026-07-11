local pack = require 'custom.pack'

local specs = {
  { src = pack.gh 'jake-stewart/multicursor.nvim', version = '1.0' },
}

local function setup()
  local mc = require 'multicursor-nvim'

  mc.setup()

  mc.addKeymapLayer(function(layer_set)
    layer_set({ 'n', 'x' }, '[m', mc.prevCursor)
    layer_set({ 'n', 'x' }, ']m', mc.nextCursor)
    layer_set({ 'n', 'x' }, '<leader>mcx', mc.deleteCursor)
    layer_set('n', '<esc>', function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end)
  end)

  local hl = vim.api.nvim_set_hl
  hl(0, 'MultiCursorCursor', { reverse = true })
  hl(0, 'MultiCursorVisual', { link = 'Visual' })
  hl(0, 'MultiCursorSign', { link = 'SignColumn' })
  hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
  hl(0, 'MultiCursorDisabledCursor', { reverse = true })
  hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
  hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
end

local load = pack.lazy('multicursor.nvim', specs, setup)

local function call(fn, ...)
  local args = { ... }
  return function() return require('multicursor-nvim')[fn](table.unpack(args)) end
end

pack.keymaps({
  { '<leader>mck', call('lineAddCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor add line above' },
  { '<leader>mcj', call('lineAddCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor add line below' },
  { '<leader>mcK', call('lineSkipCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor skip line above' },
  { '<leader>mcJ', call('lineSkipCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor skip line below' },
  { '<leader>mcn', call('matchAddCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor add next match' },
  { '<leader>mcN', call('matchAddCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor add previous match' },
  { '<leader>mcs', call('matchSkipCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor skip next match' },
  { '<leader>mcS', call('matchSkipCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor skip previous match' },
  { '<leader>mcA', call 'matchAllAddCursors', mode = { 'n', 'x' }, desc = 'Multicursor add all matches' },
  { '<leader>mc/', call('searchAddCursor', 1), desc = 'Multicursor add next search result' },
  { '<leader>mc?', call('searchAddCursor', -1), desc = 'Multicursor add previous search result' },
  { '<leader>mc*', call 'searchAllAddCursors', desc = 'Multicursor add all search results' },
  { '<leader>mc-', call('searchSkipCursor', 1), desc = 'Multicursor skip next search result' },
  { '<leader>mc_', call('searchSkipCursor', -1), desc = 'Multicursor skip previous search result' },
  { '<leader>mco', call 'operator', mode = { 'n', 'x' }, desc = 'Multicursor operator' },
  { '<leader>mcq', call 'toggleCursor', mode = { 'n', 'x' }, desc = 'Multicursor toggle cursor' },
  { '<leader>mcQ', call 'duplicateCursors', mode = { 'n', 'x' }, desc = 'Multicursor duplicate cursors' },
  { '<leader>mcr', call 'restoreCursors', desc = 'Multicursor restore cursors' },
  { '<leader>mca', call 'alignCursors', desc = 'Multicursor align cursors' },
  { '<leader>mci', call 'insertVisual', mode = 'x', desc = 'Multicursor insert visual lines' },
  { '<leader>mcI', call 'appendVisual', mode = 'x', desc = 'Multicursor append visual lines' },
  { '<leader>mcl', call 'splitCursors', mode = 'x', desc = 'Multicursor split selections' },
  { '<leader>mcm', call 'matchCursors', mode = 'x', desc = 'Multicursor match in selections' },
  { '<leader>mct', call('transposeCursors', 1), mode = 'x', desc = 'Multicursor transpose selections' },
  { '<leader>mcT', call('transposeCursors', -1), mode = 'x', desc = 'Multicursor reverse transpose selections' },
  { '<leader>mc+', call 'sequenceIncrement', mode = { 'n', 'x' }, desc = 'Multicursor increment sequence' },
  { '<leader>mc=', call 'sequenceDecrement', mode = { 'n', 'x' }, desc = 'Multicursor decrement sequence' },
  { '<leader>mcdj', call('diagnosticAddCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor add next diagnostic' },
  { '<leader>mcdk', call('diagnosticAddCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor add previous diagnostic' },
  { '<leader>mcdJ', call('diagnosticSkipCursor', 1), mode = { 'n', 'x' }, desc = 'Multicursor skip next diagnostic' },
  { '<leader>mcdK', call('diagnosticSkipCursor', -1), mode = { 'n', 'x' }, desc = 'Multicursor skip previous diagnostic' },
  {
    '<leader>mcde',
    function() require('multicursor-nvim').diagnosticMatchCursors { severity = vim.diagnostic.severity.ERROR } end,
    mode = { 'n', 'x' },
    desc = 'Multicursor match error diagnostics',
  },
  { '<c-leftmouse>', call 'handleMouse', desc = 'Multicursor mouse cursor' },
  { '<c-leftdrag>', call 'handleMouseDrag', desc = 'Multicursor mouse drag' },
  { '<c-leftrelease>', call 'handleMouseRelease', desc = 'Multicursor mouse release' },
}, load)
