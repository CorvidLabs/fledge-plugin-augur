## ADDED

### REQUIREMENT REQ-fledge-augur-plugin-001

The plugin SHALL register `fledge augur` with the released `fledge-augur` binary.

Acceptance Criteria

- The manifest exposes one `augur` command and requires no execution, storage, or metadata capability grants.

### REQUIREMENT REQ-fledge-augur-plugin-002

The plugin SHALL expose deterministic `check` and `gate` commands over working-tree, staged, or range scopes.

Acceptance Criteria

- Shared repository and scope arguments reach AugurKit and both human and JSON output remain available.

### REQUIREMENT REQ-fledge-augur-plugin-003

The plugin SHALL propagate gate failures when the assessed verdict reaches the configured threshold.

Acceptance Criteria

- `check` reports risk without failing for the verdict, while `gate` exits non-zero at or above its threshold.
