---
name: Feature request
about: Suggest an idea for this project.
title: ""
type: Feature
---

# Expose parser toggles in Oxfmt configuration for formatter use

## Summary

`oxfmt` would be easier to adopt in mixed or non-default syntax environments if formatter parsing could be configured explicitly instead of relying only on filename heuristics and built-in defaults.

I am specifically interested in parser toggles in the same general category as:

- `unsafeParameterDecoratorsEnabled`
- TS-side JSX or filetype flexibility where a project intentionally uses non-default parsing rules

## Current state

- `oxfmt` docs do not expose formatter parser options similar to Biome's parser config surface:
  - https://oxc.rs/docs/guide/usage/formatter/config-file-reference
  - https://biomejs.dev/reference/configuration/
- Merged PR `#14605` already improved one important case by enabling JSX for all JS source types:
  - https://github.com/oxc-project/oxc/pull/14605

That PR helps a lot, but it does not provide a general parser-option surface for formatter use.

## Why this matters

- Real projects sometimes use syntax that is valid for their toolchain but not part of the formatter's default parse mode.
- Formatter adoption gets blocked when parsing is almost right but missing one explicit opt-in.
- This is especially painful in editor integrations, where users want formatting to match the project's actual parser expectations.

## Suggested change

Add an explicit `parser` section to `oxfmt` config, `overrides`, and/or LSP formatting options.

Example shape:

```json
{
  "parser": {
    "unsafeParameterDecoratorsEnabled": true
  }
}
```

Even a small initial set would help. Exact option names are less important than having a supported place to opt into parser behavior intentionally.

## Example cases

Parameter decorators:

```ts
class Service {
  constructor(@inject(TOKEN) private readonly dep: Dependency) {}
}
```

TS-side JSX flexibility:

```ts
export const view = <div className="ok" />;
```

If the parser can support cases like these behind explicit flags, the formatter should ideally have a way to opt into the same behavior.

## Additional context

If maintainers prefer keeping aggressive filename-based defaults, per-override parser flags would still be a big improvement.
