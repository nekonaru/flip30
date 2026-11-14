---
name: Rule proposal
about: Propose a new rule for the official rotation
title: "[Rule] "
labels: rule-proposal
assignees: ''
---

## Rule name

<!-- ALL CAPS, Indonesian or Indonesian-flavored, e.g. "GRAVITASI SANTAI" -->

## Effect

<!-- Exactly what changes during the 30 seconds the rule is active. -->

## Tags

<!-- Which subsystem does it touch? control / gravity / speed / scoring / colors / vision / new? -->

## Why it's fun

<!-- What does the player *re-learn*? Is there a counter-play? -->

## apply() / revert() sketch

```lua
return {
  name = "NAMA ATURAN",
  tags = { "..." },
  apply = function(ctx) end,
  revert = function(ctx) end,
}
```

## Reversibility check

<!-- What state does apply() touch, and how exactly does revert() restore it? -->
