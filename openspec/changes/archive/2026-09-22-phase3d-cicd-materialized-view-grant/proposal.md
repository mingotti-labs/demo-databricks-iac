## Why

The CI/CD service principal's dev-scoped ACNC ingestion pipeline
(`phase3d-acnc-charity-register-ingestion`, `demo-databricks-mdp`) failed
its first real run with `PERMISSION_DENIED: User does not have CREATE
MATERIALIZED VIEW on Schema 'mdp_dev.bronze_acnc'` — confirmed via pipeline
event logs, not assumed. `CREATE_TABLE` (granted in
`phase3b-cicd-pipeline-grants`) does not cover Materialized Views in Unity
Catalog; it's a genuinely separate privilege (confirmed via the Terraform
provider's own privilege enum, which also confirms there is no equivalent
separate privilege for Streaming Tables — those fall under `CREATE_TABLE`,
which is why Neon's and clickstream's Streaming-Table-based pipelines never
hit this). UNGM's `unspsc_public_raw` is also a Materialized View and has
never actually been run under the CI/CD SP (confirmed via an empty
`databricks pipelines list-updates` on its SP-owned copy) — it would hit the
identical gap the first time it does.

## What Changes

- Add `CREATE_MATERIALIZED_VIEW` to the CI/CD SP's existing schema-level
  grant (`databricks_grants.cicd_schema_use`), alongside `USE_SCHEMA` and
  `CREATE_TABLE`, across every bronze-family schema in all three
  environments — applied proactively (not per-schema) since any
  Materialized-View-based source hits the same gap

## Capabilities

### Modified Capabilities
- `identity-governance`: the "CI/CD service principal schema access"
  requirement gains `CREATE_MATERIALIZED_VIEW`

## Impact

- Updates `databricks_grants.cicd_schema_use` in place (no resources
  added/destroyed — same 18 grant resources, one more privilege each)
- No impact on any other principal's access
