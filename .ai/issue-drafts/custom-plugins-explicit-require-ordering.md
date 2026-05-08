# Document explicit custom plugin requires when order matters

## Summary

Kickstart's new `vim.pack` setup has a helpful convenience loader:

```lua
-- require 'custom.plugins'
```

That should stay. I think the docs/comments should also mention the explicit ordered form for custom plugin modules where setup order matters:

```lua
require 'custom.plugins.colorscheme'
require 'custom.plugins.ui'
require 'custom.plugins.git'
```

## Current code

`lua/custom/plugins/init.lua` currently auto-loads every Lua file in `lua/custom/plugins/`:

```lua
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir) do
  if type == 'file' and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end
```

That is good for simple independent modules. With `vim.pack`, though, plugin files are imperative Lua and may call `vim.pack.add`, define commands/keymaps, or immediately run `setup()`, so load order can matter.

## Suggested change

Update the `init.lua` comment to support both paths:

```lua
  -- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --
  -- For simple independent modules, uncomment this convenience loader:
  -- require 'custom.plugins'
  --
  -- If a custom module depends on another plugin or module being set up first,
  -- require modules explicitly in the order they should run:
  --
  -- require 'custom.plugins.colorscheme'
  -- require 'custom.plugins.ui'
  -- require 'custom.plugins.git'
```
