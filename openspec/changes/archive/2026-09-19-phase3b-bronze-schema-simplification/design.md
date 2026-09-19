## Context

See proposal.md - Why. This follows directly from `phase3b-clickstream-volume`,
whose design.md deliberately did not add a `bronze_clickstream_history` sibling
schema, flagging the question instead. Resolved via direct discussion: remove
the `_history` pattern entirely rather than extend it — every existing
`_history` schema has sat empty since Phase 1, and the project is moving to a
`_raw` + `_publish` model, where `_publish` holds `<table>_scd1`/`<table>_scd2`
tables (built in `demo-databricks-mdp`, not this repo).

## Goals / Non-Goals

**Goals:**
- Match the schema list to what's actually used, not what was speculatively
  reserved in Phase 1
- Give clickstream the same `_publish` schema every other source has, so its
  upcoming SCD1 table (a follow-up `demo-databricks-mdp` change) has somewhere
  to land

**Non-Goals:**
- Building the SCD1/SCD2 tables themselves — schema provisioning only, the
  tables are `demo-databricks-mdp`'s job
- Any change to `bronze_neon`, `bronze_neon_publish`, `bronze_atlas`,
  `bronze_atlas_publish`, or `bronze_clickstream` themselves

## Decisions

**Remove `_history`, don't leave it unused.**
An empty, reserved-for-later schema that's existed since Phase 1 with nothing
ever built against it is exactly the kind of speculative infrastructure this
project's own conventions warn against. Confirmed empty via `databricks tables
list mdp_<env> bronze_<source>_history` against all six instances (2 schemas ×
3 environments) before removing — not assumed.

**`_history`'s original purpose is superseded by `_publish`'s SCD2 tables, not
replaced 1:1.**
`_history`'s stated purpose (Phase 1's schema comment: "Full history /
before-image records") is exactly what a `<table>_scd2` table already
captures — versioned rows with valid-from/valid-to semantics — and SCD2 is
more directly queryable than a raw append-only history table would have been.
No functionality is lost, just relocated to where it's actually consumed.

**No `force_destroy` needed.**
Both schemas are confirmed empty; an empty schema deletes cleanly via the
provider without setting `force_destroy = true` on the resource.

## Risks / Trade-offs

- [Destroying a schema is one-way — if something unexpectedly depended on it,
  this would fail or break silently rather than loudly] → Mitigation:
  confirmed empty via a real `databricks tables list` call against all six
  instances (not assumed), and grepped `demo-databricks-mdp` for any reference
  to `bronze_neon_history`/`bronze_atlas_history` — none found, in bundle
  config, pipeline source, or docs.

## Migration Plan

Destructive but low-risk (empty schemas, confirmed). Apply, verify the schema
list matches the new spec exactly (nine schemas, no `_history`) via
`databricks schemas list` per environment, then proceed to the
`demo-databricks-mdp` changes that write into `bronze_neon_publish` and
`bronze_clickstream_publish`. Rollback: schemas can be recreated from
Terraform config if ever needed — nothing is lost since both were empty.
