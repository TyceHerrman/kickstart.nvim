local pack = require 'custom.pack'

local image_filetypes = { 'markdown', 'quarto', 'rmd', 'vimwiki' }

local function without_obsidian_size(image_path) return vim.split(image_path, '|', { plain = true })[1] end

local function file_exists(path)
  local stat = type(path) == 'string' and path ~= '' and vim.uv.fs_stat(path)
  return stat and stat.type == 'file'
end

local function obsidian_attachment_path(image_path)
  local ok, attachment = pcall(require, 'obsidian.attachment')
  if not ok or not Obsidian or not Obsidian.dir then return nil end

  local path = attachment.resolve_attachment_path(without_obsidian_size(image_path))
  if file_exists(path) then return path end
end

local function resolve_markdown_image(document_path, image_path, fallback)
  if vim.fn.fnamemodify(image_path, ':p') == image_path and file_exists(image_path) then return image_path end

  if document_path and document_path:find(vim.fn.expand '~/obsidian/Obsidian Vault', 1, true) then
    return obsidian_attachment_path(image_path) or fallback(document_path, image_path)
  end

  return fallback(document_path, image_path)
end

pack.on_very_lazy(
  'image.nvim',
  { pack.gh '3rd/image.nvim' },
  function()
    require('image').setup {
      backend = 'kitty',
      processor = 'magick_cli',
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          filetypes = image_filetypes,
          resolve_image_path = resolve_markdown_image,
        },
        asciidoc = { enabled = false },
        neorg = { enabled = false },
        rst = { enabled = false },
        typst = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
      },
      max_height_window_percentage = 45,
      tmux_show_only_in_active_window = true,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = {
        'cmp_menu',
        'cmp_docs',
        'snacks_notif',
        'snacks_notif_history',
        'scrollview',
        'scrollview_sign',
      },
      hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
    }
  end
)
