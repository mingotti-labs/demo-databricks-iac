## Context

See proposal.md - Why. Same shape as UNGM's onboarding
(`phase3c-ungm-schema`): a public, unauthenticated, no-pagination HTTPS
source needing no credential, connection, or volume — just the schema
pair. Confirmed via a real fetch before any design work started:
`raw.githubusercontent.com/ipregistry/iso3166/master/countries.csv` and
`.../subdivisions.csv` both return `200` with no WAF/User-Agent block
(unlike `iso.org` itself, which returned a real `403` to a direct fetch —
the same class of block already seen with UNGM/ACNC/NSW Spatial's APIs,
just on the *official* ISO site rather than the mirror actually being used).

## Goals / Non-Goals

**Goals:**
- Schema pair (`bronze_iso`/`bronze_iso_publish`) provisioned in all three
  environment catalogs, ready for `demo-databricks-mdp`'s ingestion change
- CI/CD SP grants applied proactively (`USE_SCHEMA`/`CREATE_TABLE`/
  `CREATE_MATERIALIZED_VIEW`), not discovered via a failure

**Non-Goals:**
- Any new cloud infra (bucket, credential, connection, volume) — not needed,
  same as UNGM/ACNC/NSW Spatial
- Choosing or validating the actual ISO data source/format — that's
  `phase3i-iso-country-reference-ingestion`'s job in `demo-databricks-mdp`;
  this change only provisions the landing schemas

## Decisions

**Named `bronze_iso`, not `bronze_iso3166` or `bronze_iso_reference`.**
Matches every other bronze schema's naming — the source system's own name
(`iso`), not the specific standard within it (3166) or a generic qualifier.
Room exists for a future `bronze_iso_publish.currency_codes_scd1`-style
addition (ISO 4217) under the same schema pair without renaming, should
that ever be pursued — not scoped now.

**CI/CD SP grants applied proactively, including `CREATE_MATERIALIZED_VIEW`.**
Every table in `bronze_iso`/`bronze_iso_publish` will be a Materialized
View (small, full-refresh reference data — see the mdp change's design.md).
Applying the grant now avoids the exact `PERMISSION_DENIED: CREATE
MATERIALIZED VIEW` failure ACNC's onboarding hit reactively.

## Risks / Trade-offs

- [`phase3j-geonames-schema` modifies the same requirement text and is
  sequenced to land after this one] → Mitigation: explicit sequencing note
  in both changes' proposal.md; archive this one first.

## Migration Plan

Apply via `terraform plan`/`apply` following this repo's guardrails (full
plan review, explicit go-ahead before apply). Verify via `databricks
schemas list mdp_<env>` afterward. Rollback: remove the two schema map
entries and the two `cicd_writable_schemas` entries; nothing else
references them yet.
