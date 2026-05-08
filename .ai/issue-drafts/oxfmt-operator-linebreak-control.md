---
name: Feature request
about: Suggest an idea for this project.
title: ""
type: Feature
---

# Support operator-position control for wrapped binary expressions

## Summary

Please add formatter control for whether wrapped binary expressions break before or after the operator.

If support for Prettier's `experimentalOperatorPosition` is already the intended path, that would likely satisfy this request. Otherwise, a stable `operatorLinebreak`-style option would cover the same gap.

## Current state

The unsupported-features page currently lists `experimentalOperatorPosition` as not supported:

- https://oxc.rs/docs/guide/usage/formatter/unsupported-features

I do not see a documented stable equivalent in the current `oxfmt` config reference:

- https://oxc.rs/docs/guide/usage/formatter/config-file-reference

## Why this matters

- Some teams strongly prefer operators at the beginning of continuation lines.
- Other teams prefer operators at the end of the previous line.
- This is a formatting preference, not a lint rule, and it affects adoption in codebases that already have a clear established style.

## Suggested change

One of these would work:

1. support Prettier's `experimentalOperatorPosition`
2. add a stable option such as:

```json
{
  "operatorLinebreak": "before"
}
```

or

```json
{
  "operatorLinebreak": "after"
}
```

## Example

Current preference in some codebases:

```ts
if (
  conditionOne
  && conditionTwo
  && conditionThree
) {}
```

Preferred in others:

```ts
if (
  conditionOne &&
  conditionTwo &&
  conditionThree
) {}
```

Having an explicit option for this would remove one of the remaining formatter-choice blockers for teams considering `oxfmt`.
