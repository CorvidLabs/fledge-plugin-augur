---
id: CHG-0002-refresh-locked-augur-1-0-dependency
state: accepted
type: migration
base_commit: 4cf732190ca27338a60bd3ee7943e8ca9ca334cd
---

# Refresh locked Augur 1.0 dependency

## Intent

Refresh locked Augur 1.0 dependency

## Affected Canonical Specs

- None

## Acceptance Criteria

- The locked dependency resolves to the declared stable 1.0 release and the native verify lane passes

## No-spec Rationale

Refresh the lockfile to the already-declared stable 1.0 component without changing plugin behavior.
