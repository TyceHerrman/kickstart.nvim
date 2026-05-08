---
name: Feature request
about: Suggest an idea for this project.
title: ""
type: Feature
---

# Document that `semi: false` maps to `AsNeeded` semicolon behavior

## Summary

Biome exposes semicolon behavior as:

- `"always"`
- `"asNeeded"`

`oxfmt` currently documents only a boolean `semi` option. The source code shows that `semi: false` maps directly to `Semicolons::AsNeeded`, but the public docs do not make that equivalence obvious.

## Current state

- `oxfmt` config docs currently document:
  - `semi: boolean`
  - "Print semicolons at the ends of statements."
  - https://oxc.rs/docs/guide/usage/formatter/config-file-reference
- In the codebase, `semi: false` maps directly to `Semicolons::AsNeeded`:
  - `apps/oxfmt/src/core/options/to_oxc_formatter.rs`
  - `crates/oxc_formatter/src/options.rs`
- Biome documents:
  - `javascript.formatter.semicolons: "always" | "asNeeded"`
  - https://biomejs.dev/reference/configuration/

## Why this matters

- Config migration is easier when the intended semantic mapping is explicit.
- Right now the code answers the question, but the docs do not.
- Since `semi: false` already means "only print semicolons where needed because of ASI", the docs should say that directly.

## Suggested change

Document explicitly that `semi: false` is the equivalent of an `asNeeded` semicolon mode.

Optional follow-up: add an explicit alias or enum spelling if maintainers think that improves migration clarity, but documentation alone may be enough.

## Example

The practical question for users migrating from Biome is whether this:

```json
{
  "semi": false
}
```

is already equivalent to:

```json
{
  "javascript": {
    "formatter": {
      "semicolons": "asNeeded"
    }
  }
}
```

From the source, the answer appears to be yes. I think clearer docs would likely be enough.
