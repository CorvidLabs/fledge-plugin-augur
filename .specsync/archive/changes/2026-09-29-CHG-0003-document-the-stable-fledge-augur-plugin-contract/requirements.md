---
change: CHG-0003-document-the-stable-fledge-augur-plugin-contract
artifact: requirements
---

# Requirements

- Fledge discovers one `augur` command backed by the release binary.
- `check` reports deterministic risk without failing for a risk verdict.
- `gate` propagates a non-zero status when the assessed verdict reaches its threshold.
