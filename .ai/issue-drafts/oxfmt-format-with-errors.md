---
name: Feature request
about: Suggest an idea for this project.
title: ""
type: Feature
---

# Support best-effort formatting for JS/TS files with syntax errors

## Summary

`oxfmt` appears to require a successful parse before it can format a file. For editor and LSP use, a best-effort mode for invalid or incomplete code would make formatting much more useful while a file is mid-edit.

Biome has a formatter-side `formatWithErrors` option, and that workflow is especially helpful during active editing.

## Current state

- The current `oxfmt` configuration docs do not list an option equivalent to `formatWithErrors`:
  - https://oxc.rs/docs/guide/usage/formatter/config-file-reference
- The unsupported-features page does not mention a planned equivalent:
  - https://oxc.rs/docs/guide/usage/formatter/unsupported-features

## Why this matters

- Editors often trigger formatting before a file is fully valid.
- During active edits, developers still want indentation, spacing, and surrounding valid regions normalized.
- Right now the fallback is often "no formatting at all until the parse error is fixed".

## Suggested change

Add a formatter option for best-effort formatting when the file contains syntax errors.

Possible shapes:

- `formatWithErrors: true`
- a CLI flag for editor integrations

The scope can be explicitly best-effort:

- no guarantee of perfectly stable output on malformed input
- preserve current strict behavior by default
- only opt in when users or editors request it

## Example

```ts
function render() {
  return (
    <Component
      foo={bar}
      baz=
    />
  )
}
```

Even if this file cannot be fully parsed, it is still useful if the formatter can preserve or improve indentation around the valid regions instead of failing the entire format request.

## Additional context

This request is mainly about editor ergonomics, not changing strict CI formatting defaults.
