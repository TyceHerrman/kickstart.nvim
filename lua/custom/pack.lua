local M = {}

local loaded = {}
local builds = {}

function M.gh(repo) return 'https://github.com/' .. repo end

local function as_list(specs)
  if type(specs) == 'string' or specs.src then return { specs } end
  return specs
end

local function spec_name(spec)
  if type(spec) == 'table' and spec.name then return spec.name end

  local src = type(spec) == 'table' and spec.src or spec
  local name = src:gsub('%.git$', ''):match '/([^/]+)$' or src
  return name
end

local function packadd(spec) pcall(vim.cmd.packadd, spec_name(spec)) end

function M.add(specs, opts)
  opts = vim.tbl_extend('force', { confirm = false }, opts or {})
  vim.pack.add(as_list(specs), opts)
end

function M.build(name, command) builds[name] = command end

function M.run_build(event)
  if event.data.kind ~= 'install' and event.data.kind ~= 'update' then return end

  local build = builds[event.data.spec.name]
  if not build then return end

  if type(build) == 'function' then
    build(event.data)
    return
  end

  if build:sub(1, 1) == ':' then
    vim.cmd(build:sub(2))
    return
  end

  vim.system(vim.split(build, ' '), { cwd = event.data.path })
end

function M.eager(specs, setup)
  M.add(specs, { load = true })
  if setup then setup() end
end

function M.lazy(id, specs, setup)
  specs = as_list(specs)
  M.add(specs, { load = false })

  return function()
    if loaded[id] then return end

    for _, spec in ipairs(specs) do
      packadd(spec)
    end

    if setup then setup() end

    loaded[id] = true
  end
end

function M.on_event(events, id, specs, setup)
  vim.api.nvim_create_autocmd(events, {
    once = true,
    callback = M.lazy(id, specs, setup),
  })
end

function M.on_very_lazy(id, specs, setup)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = M.lazy(id, specs, setup),
  })
end

function M.on_ft(filetypes, id, specs, setup)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    once = true,
    callback = M.lazy(id, specs, setup),
  })
end

function M.on_cmd(commands, id, specs, setup)
  local load = M.lazy(id, specs, setup)

  for _, command in ipairs(as_list(commands)) do
    vim.api.nvim_create_user_command(command, function(args)
      pcall(vim.api.nvim_del_user_command, command)
      load()
      local bang = args.bang and '!' or ''
      local suffix = args.args ~= '' and (' ' .. args.args) or ''
      vim.cmd(command .. bang .. suffix)
    end, { bang = true, nargs = '*', complete = 'file' })
  end
end

function M.keymaps(keys, load)
  for _, key in ipairs(keys) do
    local lhs = key[1]
    local rhs = key[2]
    local opts = vim.tbl_extend('force', key, {})
    opts[1], opts[2] = nil, nil
    local mode = opts.mode or 'n'
    if mode == '' then mode = { 'n', 'v' } end
    opts.mode = nil

    if load then
      if type(rhs) == 'function' then
        local fn = rhs
        rhs = function(...)
          load()
          return fn(...)
        end
      else
        local command = rhs
        rhs = function()
          load()
          vim.cmd(command:gsub('^<cmd>', ''):gsub('^<Cmd>', ''):gsub('<[cC][rR]>$', ''))
        end
      end
    end

    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return M
