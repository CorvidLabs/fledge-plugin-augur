---
change: CHG-0003-document-the-stable-fledge-augur-plugin-contract
artifact: testing
---

# Testing

- `bash Tests/plugin_contract_test.sh`
- `swift build -c release`
- `specsync check --strict --require-coverage 100 --force`
- `fledge trust verify`
