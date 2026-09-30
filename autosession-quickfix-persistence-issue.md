# [FEATURE] Preserve complete quickfix state across sessions

**Is your feature request related to a problem? Please describe.**

The README recipe restores the current global quickfix list and title, then always runs `copen`. It does not preserve:

- the quickfix stack used by `:colder` and `:cnewer`;
- the selected list and current entry;
- whether the quickfix window was open;
- an empty session state, so quickfix data from the previous session can remain when the restored session has none.

Window visibility also cannot be captured reliably inside `save_extra_cmds` during autosave: `close_unsupported_windows()` closes the quickfix window before the save hooks run.

**Describe the solution you'd like**

Provide a supported quickfix persistence helper, or the lifecycle support needed by an expanded recipe, that:

1. Captures quickfix state before unsupported windows are closed.
2. Saves every list in the global quickfix stack, including each list's entries, title, context, and current index.
3. Records the selected list and whether the quickfix window was open.
4. Clears the existing quickfix stack before restoration so state cannot leak between sessions.
5. Reconstructs the stack, selected list, and current entry, and opens the window only when it was previously open.
6. Restores an explicitly empty state by clearing stale quickfix data.

This proposal is limited to the global quickfix stack. Window-local location lists can be handled separately because they require mapping restored windows to their saved lists.

**Describe alternatives you've considered**

- The current README recipe is sufficient when only the current list matters and unconditional `copen` is desired.
- User hooks can serialize the stack, but the current autosave ordering prevents them from reliably observing window visibility.
- Neovim does not currently provide a `sessionoptions` value that persists quickfix state.

**Additional context**

This would turn the general request in #173 into defined, testable session behavior. Neovim exposes the required stack information through `getqflist()` and restoration through `setqflist()`; AutoSession mainly needs to provide the correct capture and restore lifecycle.
