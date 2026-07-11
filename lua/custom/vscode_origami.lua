local M = {}

local origami_config = require 'custom.origami_config'
local vscode = require 'vscode'

local helper_script = [[
const helperVersion = 1;

if (!globalThis.__nvimOrigami || globalThis.__nvimOrigami.version !== helperVersion) {
  globalThis.__nvimOrigami = (() => {
    const publicCommands = [
      'editor.fold',
      'editor.unfold',
      'editor.foldRecursively',
      'editor.unfoldRecursively',
    ];
    const internalCandidates = [
      '_executeFoldingRangeProvider',
      'vscode.executeFoldingRangeProvider',
      'editor.toggleFold',
      'editor.toggleFoldRecursively',
    ];
    let commandSet;

    async function commands() {
      if (!commandSet) {
        commandSet = new Set(await vscode.commands.getCommands(true));
      }
      return commandSet;
    }

    function visibleSnapshot(editor) {
      return editor.visibleRanges
        .map((range) => `${range.start.line}:${range.start.character}-${range.end.line}:${range.end.character}`)
        .join('|');
    }

    function clampLine(editor, line) {
      const parsed = Number(line);
      if (!Number.isFinite(parsed)) {
        return 0;
      }
      return Math.min(Math.max(Math.floor(parsed), 0), editor.document.lineCount - 1);
    }

    function sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    }

    async function settle() {
      await sleep(0);
      await sleep(0);
    }

    async function withLineSelection(editor, line, callback) {
      const originalSelections = editor.selections;
      const position = new vscode.Position(line, 0);
      editor.selections = [new vscode.Selection(position, position)];
      await settle();

      try {
        return await callback();
      } finally {
        editor.selections = originalSelections;
        await settle();
      }
    }

    async function runEditorCommand(editor, command, commandArgs) {
      const before = visibleSnapshot(editor);
      if (commandArgs === undefined) {
        await vscode.commands.executeCommand(command);
      } else {
        await vscode.commands.executeCommand(command, commandArgs);
      }
      await settle();
      const after = visibleSnapshot(editor);

      return {
        ok: true,
        backend: 'vscode-commands-visible-range',
        command,
        changed: before !== after,
      };
    }

    async function lineCommand(args, command, useSelection) {
      const editor = vscode.window.activeTextEditor;
      if (!editor) {
        return { ok: false, changed: false, reason: 'no-active-editor' };
      }

      const line = clampLine(editor, args.line);
      const availableCommands = await commands();
      if (!availableCommands.has(command)) {
        return { ok: false, changed: false, reason: 'missing-command', command };
      }

      if (useSelection) {
        return await withLineSelection(editor, line, () => runEditorCommand(editor, command));
      }

      return await runEditorCommand(editor, command, { selectionLines: [line] });
    }

    async function status() {
      const availableCommands = await commands();
      const commandStatus = {};
      for (const command of publicCommands) {
        commandStatus[command] = availableCommands.has(command);
      }

      const internalStatus = {};
      for (const command of internalCandidates) {
        internalStatus[command] = availableCommands.has(command);
      }

      return {
        backend: 'vscode-commands-visible-range',
        commands: commandStatus,
        internalCandidates: internalStatus,
      };
    }

    async function run(args) {
      switch (args.method) {
        case 'fold':
          return await lineCommand(args, 'editor.fold', false);
        case 'unfold':
          return await lineCommand(args, 'editor.unfold', false);
        case 'foldRecursive':
          return await lineCommand(args, 'editor.foldRecursively', true);
        case 'unfoldRecursive':
          return await lineCommand(args, 'editor.unfoldRecursively', true);
        case 'status':
          return await status();
        default:
          return { ok: false, changed: false, reason: `unknown-method:${args.method}` };
      }
    }

    return { version: helperVersion, run };
  })();
}

return await globalThis.__nvimOrigami.run(args);
]]

local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

local function current_line() return vim.api.nvim_win_get_cursor(0)[1] - 1 end

local function should_close_fold()
  local fold_keymaps = origami_config.fold_keymaps()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local text_before_cursor = vim.api.nvim_get_current_line():sub(1, col)
  local on_indent_or_first_non_blank = text_before_cursor:match '^%s*$' and not fold_keymaps.closeOnlyOnFirstColumn
  local first_char = col == 0 and fold_keymaps.closeOnlyOnFirstColumn

  return on_indent_or_first_non_blank or first_char
end

local function run_vscode(method)
  local ok, result = pcall(vscode.eval, helper_script, { args = { method = method, line = current_line() } }, 1000)
  if not ok or type(result) ~= 'table' then return false end

  return result.ok == true and result.changed == true
end

function M.h()
  local count = vim.v.count1
  for _ = 1, count do
    if should_close_fold() then
      local was_folded = run_vscode 'fold'
      if not was_folded then normal 'h' end
    else
      normal 'h'
    end
  end
end

function M.caret()
  local fold_keymaps = origami_config.fold_keymaps()
  local cmd = fold_keymaps.scrollLeftOnCaret and '0^' or '^'

  if should_close_fold() then
    local was_folded = run_vscode 'foldRecursive'
    if not was_folded then normal(cmd) end
  else
    normal(cmd)
  end
end

function M.l()
  local count = vim.v.count1
  for _ = 1, count do
    local was_unfolded = run_vscode 'unfold'
    if not was_unfolded then normal 'l' end
  end
end

function M.dollar()
  local was_unfolded = run_vscode 'unfoldRecursive'
  if not was_unfolded then normal '$' end
end

function M.status()
  local ok, result = pcall(vscode.eval, helper_script, { args = { method = 'status' } }, 1000)
  if not ok then
    vim.notify('VS Code Origami status failed: ' .. result, vim.log.levels.WARN)
    return
  end

  vim.notify(vim.inspect(result), vim.log.levels.INFO, { title = 'VS Code Origami' })
end

function M.setup()
  vim.keymap.set('n', 'h', M.h, { desc = 'Origami h (VS Code folds)' })
  vim.keymap.set('n', 'l', M.l, { desc = 'Origami l (VS Code folds)' })
  vim.keymap.set('n', '^', M.caret, { desc = 'Origami ^ (VS Code folds)' })
  vim.keymap.set('n', '$', M.dollar, { desc = 'Origami $ (VS Code folds)' })

  vim.api.nvim_create_user_command('VscodeOrigamiStatus', M.status, {
    desc = 'Show VS Code Origami folding backend status',
  })
end

return M
