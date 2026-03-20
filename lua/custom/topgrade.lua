local M = {}

local LAZY_SYNC_MARKER = 'Lazy! sync | qa'

local is_update_session
local prepared_update_session
local lazy_sync_started

-- Snapshot of the originally sourced script; cached_lines is never mutated.
-- Callers receive fresh tables so cache state cannot diverge from disk on write failure.
local cached_script_path
local cached_lines

local function get_update_script_path(argv)
  for i, arg in ipairs(argv) do
    if arg == '-S' or arg == '-nS' then
      return argv[i + 1]
    end

    local inline_script = arg:match('^%-S(.+)$')
    if inline_script then
      return inline_script
    end
  end
end

local function read_update_script()
  if cached_script_path then
    return cached_script_path, vim.list_extend({}, cached_lines)
  end

  local script_path = get_update_script_path(vim.v.argv)
  if not script_path then
    return
  end

  local script_stat = vim.uv.fs_stat(script_path)
  if not script_stat or script_stat.type ~= 'file' then
    return
  end

  local ok, lines = pcall(vim.fn.readfile, script_path)
  if not ok then
    return
  end

  cached_script_path = script_path
  cached_lines = lines

  return script_path, vim.list_extend({}, lines)
end

function M.is_update_session()
  if is_update_session ~= nil then
    return is_update_session
  end

  local result = false

  if vim.tbl_contains(vim.v.argv, '--headless') then
    local _, lines = read_update_script()
    if lines then
      local script = table.concat(lines, '\n')
      result = script:find(LAZY_SYNC_MARKER, 1, true) ~= nil
    end
  end

  is_update_session = result
  return is_update_session
end

function M.prepare_update_session()
  if prepared_update_session ~= nil then
    return prepared_update_session
  end

  local result = false

  if M.is_update_session() then
    local script_path, lines = read_update_script()
    if script_path and lines then
      local updated = false
      local rewritten = {}
      for _, line in ipairs(lines) do
        if line:find(LAZY_SYNC_MARKER, 1, true) then
          local indent = line:match('^%s*') or ''
          -- Topgrade sources this script after init.lua. Swap in an async sync entrypoint
          -- and finish the script so it does not fall through to Topgrade's later quitall.
          table.insert(rewritten, indent .. [[lua require("custom.topgrade").run_lazy_sync()]])
          table.insert(rewritten, indent .. 'finish')
          updated = true
        else
          table.insert(rewritten, line)
        end
      end

      if updated then
        local ok = pcall(vim.fn.writefile, rewritten, script_path)
        result = ok
      end
    end
  end

  prepared_update_session = result
  return prepared_update_session
end

function M.run_lazy_sync()
  if lazy_sync_started then
    return
  end
  lazy_sync_started = true

  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazySync',
    once = true,
    callback = function()
      -- Topgrade runs unattended, so exit as soon as the async sync completes.
      vim.schedule(function()
        vim.cmd 'qa!'
      end)
    end,
  })

  require('lazy.manage').sync { show = false, wait = false }
end

return M
