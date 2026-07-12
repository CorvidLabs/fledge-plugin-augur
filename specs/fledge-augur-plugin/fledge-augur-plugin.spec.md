---
module: fledge-augur-plugin
version: 1
status: stable
files:
  - plugin.toml
  - Sources/fledge-augur/FledgeAugur.swift
db_tables: []
depends_on: []
---

# Fledge Augur Plugin

## Purpose

Expose AugurKit's deterministic change-risk assessment as the discoverable `fledge augur` command without requiring a separate Augur executable.

## Public API

The plugin manifest registers one command named `augur` backed by the release build at
`.build/release/fledge-augur`. Its root command exposes `check` and `gate`. Both accept
working-tree, staged, or named-range scope and a repository path. `check` supports verbose,
human, colored, and JSON reporting; `gate` accepts a proceed, review, or block threshold
and also supports JSON output.

## Invariants

1. The plugin links AugurKit directly and requires no external Augur binary.
2. Range scope takes precedence over staged scope; the working tree is the default.
3. `check` treats no changes as a proceed result and does not fail because of risk.
4. `gate` exits non-zero when the verdict is at or above its threshold.
5. The plugin manifest grants no exec, store, or metadata capabilities.

## Behavioral Examples

```text
Given a repository with staged changes
When fledge augur gate --staged --threshold review runs
Then AugurKit assesses the staged diff
And the command exits 1 for a review or block verdict
```

## Error Cases

| Error | Behavior |
| --- | --- |
| Repository path is not a Git work tree | Return AugurKit's repository validation error. |
| Threshold is not proceed, review, or block | Return an argument validation error. |
| Gate verdict reaches its threshold | Print the assessment and exit 1. |

## Dependencies

- Fledge plugin manifest contract.
- AugurKit 1.x.
- Swift Argument Parser.

## Change Log

| Version | Date | Changes |
| --- | --- | --- |
| 1 | 2026-07-12 | Stable Fledge Augur plugin contract. |
