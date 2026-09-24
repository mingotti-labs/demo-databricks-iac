## Context

See proposal.md - Why. Sixth source system, same `_raw`+`_publish` pattern
established by `phase3b-bronze-schema-simplification`, plus this project's
first real third-party secret (every prior secret is either a source
database's own connection credential from Phase 1, or a documented
placeholder with no scope created — UNGM's, per `phase3c-ungm-unspsc-ingestion`'s
design.md).

Three markets confirmed real and non-fragmented on AirROI's own site
before this was drafted (free to check, no paid API calls used): Vitória
da Conquista/BA, Urubici/SC, Tauranga/NZ. Sydney was explicitly dropped —
its plain `sydney` slug sits alongside 50+ separate Sydney-suburb pages
(Bondi, Surry Hills, Parramatta, etc.), strongly indicating it's a
generic/residual bucket, not a real Local Government Area or the Greater
Sydney metro. Tauranga has one real caveat: Papamoa (a genuine Tauranga
suburb) is a separate sibling page, so `tauranga` likely excludes it —
accepted as a minor, documented gap, not a blocker (one suburb, not the
wholesale fragmentation Sydney had).

## Goals / Non-Goals

**Goals:**
- Give AirROI the same schema shape every other source has
- Provision a real secret scope for AirROI's API key, following the exact
  mechanism already used for Neon/Atlas (Terraform-managed
  `databricks_secret`, sourced from a `sensitive` HCP Terraform workspace
  variable, never a `.tfvars` file or anything committed)

**Non-Goals:**
- Any connection/volume infrastructure beyond the secret scope — AirROI is
  a plain HTTPS REST API, no UC Connection type exists for it
- Handling AirROI's per-call cost at the infrastructure layer — cost
  discipline (which markets, how often to run) is `demo-databricks-mdp`'s
  concern, not something Terraform enforces

## Decisions

**Secret scope named `airroi`, single key `api_key`.**
Matches this project's existing scope-per-source-system convention
(`neon-postgres`, `atlas-mongodb`) — one scope per source, keys named for
what they hold. AirROI's auth is a single `X-API-KEY` header value, so one
key is sufficient (no separate host/username/password split like Neon's).

**`CREATE_MATERIALIZED_VIEW` included in the CI/CD schema grant from the
start.**
Same reasoning as `phase3f-nsw-property-schema`: this gap was discovered
reactively for ACNC and shouldn't be rediscovered a third time. AirROI's
ingestion pipeline is expected to use a Materialized View (full-refresh
pull, no incremental cursor), same shape as UNGM/ACNC/NSW property.

## Risks / Trade-offs

- [The secret value itself is invisible to this session — it was set
  directly in HCP Terraform's workspace, not passed through here] →
  Mitigation: this is the correct, secure pattern (matches Neon/Atlas
  exactly), not a gap. `terraform plan`/`apply` will read it from the
  workspace variable set the same way it already does for
  `var.neon_password`/`var.atlas_password`.

## Migration Plan

Additive only. Apply, confirm the two new schemas exist per environment
via `databricks schemas list`, confirm the `airroi` scope exists via
`databricks secrets list-scopes` and contains `api_key` via
`databricks secrets list-secrets airroi` (value itself never displayed),
then hand off to the `demo-databricks-mdp` change that consumes both.
Rollback: destroy the schemas and secret scope — nothing consumes them
until that change is built.
