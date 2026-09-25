## Context

See proposal.md - Why. Identical shape to `phase4a-silver-landing-schemas`:
two more source-aligned Silver Landing schemas, no new infra (no bucket,
credential, connection, or volume) — Silver Landing only reads from Bronze
Publish, already provisioned for both sources.

## Goals / Non-Goals

**Goals:**
- `silver_landing_iso`/`silver_landing_geonames` provisioned in all three
  environment catalogs
- CI/CD SP grants applied proactively (`USE_SCHEMA`/`CREATE_TABLE`/
  `CREATE_MATERIALIZED_VIEW`), same as every schema onboarded since ACNC's
  reactive discovery

**Non-Goals:**
- Any new cloud infra — not needed
- Silver Normalised/Domain/Marts schemas for these sources — out of scope,
  same as every other source's Silver Landing onboarding

## Decisions

**Named `silver_landing_iso`/`silver_landing_geonames`, matching the
source's own bronze schema name** — same convention `phase4a-silver-landing-schemas`
established, one schema per source system, not per entity.

**CI/CD SP grants applied proactively, including `CREATE_MATERIALIZED_VIEW`.**
Every Silver Landing table is a Materialized View — same reasoning as
every schema onboarded since NSW Spatial's/AirROI's proactive grants.

## Risks / Trade-offs

None beyond the standard "confirmed via `terraform plan`" discipline —
purely additive, same shape as five prior schema-onboarding changes.

## Migration Plan

Apply via `terraform plan`/`apply` following this repo's guardrails (full
plan review, explicit go-ahead before apply). Verify via `databricks
schemas list mdp_<env>` afterward. Rollback: remove the two schema map
entries and the two `cicd_writable_schemas` entries; nothing else
references them yet.
