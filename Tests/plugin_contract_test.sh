#!/usr/bin/env bash
set -euo pipefail

# Direct SDD evidence: REQ-fledge-augur-plugin-001,
# REQ-fledge-augur-plugin-002, REQ-fledge-augur-plugin-003.
grep -Fq 'name = "augur"' plugin.toml
grep -Fq 'binary = ".build/release/fledge-augur"' plugin.toml
grep -Fq 'subcommands: [Check.self, Gate.self]' Sources/fledge-augur/FledgeAugur.swift
grep -Fq 'throw ExitCode(1)' Sources/fledge-augur/FledgeAugur.swift
grep -Fq 'var threshold: String = "review"' Sources/fledge-augur/FledgeAugur.swift

echo "fledge augur plugin contract passed"
