# fledge-plugin-augur

🔮 Run [`augur`](https://github.com/CorvidLabs/augur)'s deterministic change-risk
scoring as a first-class `fledge augur` command.

A plugin for [fledge](https://github.com/CorvidLabs/fledge).

augur reads a git diff and emits a verdict (`proceed`, `review`, or `block`)
from structural signals only (churn, co-change coupling, test gaps, sensitive
paths, ownership, and the repo's own revert history). **No API key, no LLM.**

This plugin links augur's `AugurKit` library directly, so it is **self-contained**:
you do *not* need an external `augur` binary installed.

## Requirements

- **macOS only** (`AugurKit` targets `.macOS(.v13)`; the plugin builds an arm64/x86_64 macOS binary).
- A toolchain with Swift 6 to build from source (`swift build -c release`).
- **Dependency:** the plugin depends on [`CorvidLabs/augur`](https://github.com/CorvidLabs/augur)
  via Swift Package Manager, `0.1.0` or newer. `swift build` resolves it; you
  need read access to that repository for the build to fetch it.

## Install

```bash
fledge plugins install CorvidLabs/fledge-plugin-augur
```

## Usage

```bash
fledge augur check                      # assess working-tree changes, print a verdict
fledge augur check --staged             # assess staged changes only
fledge augur check --range main..HEAD   # assess a git range
fledge augur check --json               # machine-readable JSON for agents / CI
fledge augur check -v                   # show every contributing signal per file
fledge augur check -C path/to/repo      # assess a repo other than the cwd

fledge augur gate                       # exit non-zero if verdict >= review (default)
fledge augur gate --threshold block     # only block on the highest-risk verdict
fledge augur gate --json                # gate + emit JSON
```

`check` always exits `0` (it is a report). `gate` exits `1` when the verdict
meets or exceeds `--threshold` (`proceed` | `review` | `block`), making it
suitable for CI steps and agent loops.

### Design note

This plugin re-implements augur's `check` and `gate` surface as a thin shim over
`AugurKit` (`GitRepository` → `Augur.assess(scope:)` → `Reporter` / `Assessment.jsonString()`).
It intentionally covers the core verdict workflow; augur's CLI-only extras
(`.augur.toml` config, `--coverage`, `--sarif`, CODEOWNERS, `calibrate`,
`explain`) live in the `augur` CLI itself.

## License

MIT
