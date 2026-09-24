## Why

Phase 3h (not 3g — that letter is already the roadmap's optional G-NAF
item, a distinct, unrelated source) adds a sixth source system in
`demo-databricks-mdp`: AirROI's short-term rental market
intelligence API (`airroi.com/api`), pulling `/markets/summary` data for
three confirmed real markets (Vitória da Conquista/BA, Urubici/SC,
Tauranga/NZ — each verified as a clean, non-fragmented market on AirROI's
own site before this was drafted; Sydney was explicitly dropped after
confirming its plain `sydney` slug is a generic/residual bucket, not a
real Local Government Area or the full metro).

This is the **first source system in this project with a real, paid,
authenticated API** — every other source (Neon, Atlas, clickstream, UNGM,
ACNC, NSW Spatial Services) is either free/public or a private-network
credential already provisioned in Phase 1. AirROI has no free sandbox;
every call costs real money ($0.01/call), so this change also introduces
the project's first real (non-placeholder) third-party API secret.

## What Changes

- Add `bronze_airroi` and `bronze_airroi_publish` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf` — mirrors every other source
  system's schema pair, including `CREATE_MATERIALIZED_VIEW` in the CI/CD
  grant from the start (per `phase3d-cicd-materialized-view-grant`'s
  lesson, applied proactively since Phase 3d)
- Add an `airroi` secret scope to `modules/databricks-secret-scopes/main.tf`
  containing one key, `api_key`, sourced from `var.airroi_api_key` — a
  `sensitive = true` Terraform variable already set directly in the HCP
  Terraform workspace (never passed through this session, matching how
  Neon's and Atlas's credentials are handled)
- Add `bronze_airroi` and `bronze_airroi_publish` to
  `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `bronze_airroi` and `bronze_airroi_publish`
- `secret-scopes`: gains a new "AirROI secret scope" requirement, following
  the same shape as the existing Neon/Atlas requirements

## Cross-repo dependencies

Provides for an upcoming `demo-databricks-mdp` change (AirROI market
summary ingestion, SCD2 only — no SCD1, a deliberate scope decision) that
writes into `bronze_airroi`/`bronze_airroi_publish` and reads the `airroi`
secret scope's `api_key`. That change should not deploy until this one has
landed.

## Impact

- Adds 6 schema resources (`bronze_airroi` + `bronze_airroi_publish` × 3
  environments)
- Adds 6 more `cicd_schema_use` grant resources (same 2 schemas × 3
  environments)
- Adds 1 secret scope + 1 secret resource (`airroi`/`api_key`)
- No impact on any existing schema, table, grant, or secret scope
