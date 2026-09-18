## Why

The Neon project is named `mdp-dev`, but it's the one and only Neon-backed Postgres
instance for the whole platform — there's no separate `mdp-tst`/`mdp-prd` Neon
project, so the `-dev` suffix misleads. It also currently has only one branch, so
there's no real dev/prod data separation: anything built against it (starting with
Phase 3's ingestion work) would work directly against the platform's one and only
copy of the data, with no isolation between active development and anything treated
as stable. Neon's branching feature (confirmed available on this project — free tier
allows 10 branches, copy-on-write, near-instant) fixes this properly, mirroring the
git convention already used for code: `main` stays the stable line, a `dev` branch
(forked from `main`) is where active development happens — without literally renaming
`main`, the same way a git repo doesn't rename `main` to "prod" to make it the
production line.

## What Changes

- Rename the Neon project: `mdp-dev` → `mdp`
- Add a `dev` branch, forked from the existing `main` branch (kept as-is — no rename,
  matching git convention) — plus the compute endpoint and role-password lookup
  needed to actually connect to it
- ~~Protect `main`~~ — attempted, reverted: Neon's free tier allows zero protected
  branches (confirmed via a real `BRANCHES_PROTECTED_LIMIT_EXCEEDED` apply failure).
  Both branches are unprotected.
- Restructure the `neon` module's outputs from one implicit connection
  (`host`/`database_name`/`role_name`/`password`) to two explicit ones
  (`main_*`/`dev_*`)
- Re-wire the `neon-postgres` secret scope to the **`dev`** branch's connection
  details, not `main` — active development and (starting with Phase 3) ingestion
  should target `dev`, not the platform's one production-equivalent copy of the data

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `source-databases`: Neon project renamed; branch topology (`main` + `dev`) replaces
  the single implicit branch; module outputs restructured accordingly
- `secret-scopes`: `neon-postgres` now sources from the `dev` branch specifically,
  not the project's single (formerly implicit) connection

## Impact

- Renames the Neon project (`mdp-dev` → `mdp`) — verified via `terraform plan` for
  whether this is in-place or forces replacement; either is acceptable since Neon
  currently holds no data (confirmed empty ahead of this change)
- Adds a new Neon branch (`dev`), endpoint, and role-password lookup — new resources,
  clean creates, no impact on `main`
- Updates the `neon` module's output interface (`host`/`database_name`/`role_name`/
  `password` → `main_*`/`dev_*`) — the only consumer is `secret_scopes`, updated in
  the same change
- No change to Atlas — stays named `mdp-dev`; this creates a naming inconsistency
  between the two source databases, accepted for now (Atlas has no branching feature
  to mirror this pattern with; out of scope here)
