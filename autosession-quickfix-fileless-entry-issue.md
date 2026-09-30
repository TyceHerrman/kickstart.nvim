# [BUG] Quickfix recipe assigns the current buffer to fileless or non-error entries

**Describe the bug**

The README quickfix recipe converts every `bufnr` to a filename with:

```lua
entry.filename = vim.api.nvim_buf_get_name(entry.bufnr)
entry.bufnr = nil
```

`getqflist()` returns `bufnr = 0` when an entry has no existing buffer. This includes non-error entries retained from build output that does not match `'errorformat'`. Neovim APIs interpret buffer `0` as the current buffer, so these entries are saved with an unrelated filename and become file-backed after restoration.

**To reproduce**

1. Configure the quickfix recipe from the README.
2. Open a named file buffer.
3. Parse build output containing an informational line that does not match the error format:

   ```lua
   vim.fn.setqflist({}, " ", {
     lines = { "build started", "main.lua:3:failure" },
     efm = "%f:%l:%m",
   })
   ```

4. `getqflist()` returns the `"build started"` entry with `bufnr = 0` and `valid = 0`.
5. Save and restore the AutoSession session.
6. The informational entry now refers to the file that was current when the session was saved.

**Expected behavior**

Only valid, positive, named buffer references should be converted to filenames. Fileless and non-error entries should remain fileless, and unstable buffer numbers should still be removed before serialization.

```lua
for _, entry in ipairs(qflist) do
  local bufnr = entry.bufnr
  if type(bufnr) == "number" and bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename ~= "" then
      entry.filename = filename
    end
  end
  entry.bufnr = nil
end
```

**Additional context**

Neovim's `getqflist()` documentation explicitly warns that nonexistent buffer references are returned as zero and may require an explicit zero check.
