local nix_darwin_path = '/Users/tyceherrman/.config/nix-darwin'
local nix_darwin_root = assert(vim.uv.fs_realpath(nix_darwin_path))
local nix_darwin_settings_path = nix_darwin_root .. '/nixd-settings.json'

local function read_nix_darwin_settings()
  local ok, lines = pcall(vim.fn.readfile, nix_darwin_settings_path)
  assert(ok, ('failed to read %s: %s'):format(nix_darwin_settings_path, lines))

  local decoded_ok, settings = pcall(vim.json.decode, table.concat(lines, '\n'))
  assert(decoded_ok, ('failed to decode %s: %s'):format(nix_darwin_settings_path, settings))
  assert(type(settings) == 'table', ('expected %s to contain a JSON object'):format(nix_darwin_settings_path))

  return settings
end

---@type vim.lsp.Config
local config = {
  settings = {
    nixd = {
      formatting = {
        command = { 'alejandra' },
      },
    },
  },
  before_init = function(_, client_config)
    local root = client_config.root_dir and vim.uv.fs_realpath(client_config.root_dir)
    if root ~= nix_darwin_root then return end

    client_config.settings = vim.tbl_deep_extend('force', client_config.settings or {}, {
      nixd = read_nix_darwin_settings(),
    })
  end,
}

return config
