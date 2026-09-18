## Why

Phase 3a's Lakeflow Connect ingestion pipeline (query-based, built in
`demo-databricks-mdp`) needs a Unity Catalog `CONNECTION` object anchoring
credentials to Neon's `dev` branch — every Lakeflow Connect pipeline points at a UC
Connection by name; the connection owns the auth, the pipeline just references it.
UC Connections are governance objects, same family as the storage credentials this
repo already provisions, so this is Terraform's job, not something created ad hoc
from the mdp side.

## What Changes

- New module `modules/databricks-uc-connection-postgres/`: one `databricks_connection`
  (`POSTGRESQL` type) per call — generic, not Neon-specific, reusable if a second
  Postgres connection is ever needed
- Root composes one instance, `neon_dev`, wired to `module.neon`'s `dev_*` outputs
  (host/role/password) with `sslmode = "require"` set explicitly (Neon's own
  connection strings always include this; the provider's docs don't state a default,
  so it's not left to chance)
- Connectivity verified for real after apply, via a live SQL query against the
  connection — not assumed from `terraform apply` succeeding alone

## Capabilities

### New Capabilities
- `uc-connections`: UC Connection objects anchoring external-system credentials for
  Lakeflow Connect / Lakehouse Federation — distinct from `unity-catalog`'s
  catalog/schema structure

### Modified Capabilities
(none)

## Cross-repo dependencies

Provides for `phase3a-lakeflow-connect-neon` in `demo-databricks-mdp` — that
change's ingestion pipeline references the `neon_dev` connection this change
creates. That change should not be applied until this one has landed and its
connectivity is verified.

## Impact

- Adds `databricks_connection.this` (inside the new module) to Terraform state
- No impact on existing catalogs, schemas, or grants
- The connection's `password` option is a sensitive Terraform value, same handling
  as every other credential this repo already manages
