## Context

See proposal.md - Why. Confirmed via real fetches before any design work
started, against `download.geonames.org/export/dump/`:
- `countryInfo.txt` — 252 data rows, tab-delimited
- `admin1CodesASCII.txt` — 3,865 data rows
- `admin2Codes.txt` — 47,643 data rows
- `cities500.zip` — 13.86MB compressed (all cities with population > 500)

All four returned `200` directly, no WAF/User-Agent block — unlike every
API-backed source system in this project (UNGM, ACNC, NSW Spatial all
needed an explicit `User-Agent` header).

## Goals / Non-Goals

**Goals:**
- Schema pair (`bronze_geonames`/`bronze_geonames_publish`) provisioned in
  all three environment catalogs
- CI/CD SP grants applied proactively

**Non-Goals:**
- Choosing the exact GeoNames files/tables or the ingestion mechanism —
  that's `phase3j-geonames-reference-ingestion`'s job in
  `demo-databricks-mdp`
- Any new cloud infra — not needed, same reasoning as ISO's schema change

## Decisions

**Named `bronze_geonames`, not `bronze_geo` or `bronze_gazetteer`.** Matches
the source system's own name, same convention as every other bronze schema.

**CI/CD SP grants applied proactively, including `CREATE_MATERIALIZED_VIEW`.**
Same reasoning as ISO's schema change — every table here will be a
Materialized View.

## Risks / Trade-offs

- [This change's spec delta assumes `phase3i-iso-schema` has already
  landed] → Mitigation: explicit sequencing note in proposal.md; do not
  archive out of order.

## Migration Plan

Apply via `terraform plan`/`apply` following this repo's guardrails.
Verify via `databricks schemas list mdp_<env>` afterward. Rollback: remove
the two schema map entries and the two `cicd_writable_schemas` entries.
