## Context

Same shape as `phase4a-silver-landing-schemas` and
`phase4b-silver-landing-iso-geonames-schemas`: one entry in the schema map,
one in the CI/CD writable list. Naming per `demo-databricks-mdp`'s
NAMING.md: `silver_normalised_<source>`.

## Goals / Non-Goals

**Goals:** create `silver_normalised_airroi` in `mdp_dev`, `mdp_tst` and
`mdp_prd` with the grants its pipeline needs.

**Non-Goals:** Silver Normalised schemas for any other source (each is
added in its own source's change); Silver Domain/Marts schemas; governed
tags or tag policies.

## Decisions

- **One schema per normalised source, added just in time**, not all eight
  up front: most sources are not scheduled for normalisation, and each
  needs its Landing `ingested_timestamp` precondition first.
- **Same grants as Silver Landing**, including `CREATE_MATERIALIZED_VIEW`
  from the start.
- **`APPLY TAG` not granted up front.** The tag step runs as the tables'
  owner; whether ownership suffices is checked in `dev` before adding a
  grant nobody has shown is needed.

## Risks / Trade-offs

- [Tag step needs `APPLY TAG`] → found in `dev` by the mdp change; added
  in this change's implementation PR before merge.

## Migration Plan

`terraform plan` (expect 6 to add, 0 to change, 0 to destroy), apply after
explicit go-ahead, confirm with `databricks schemas list mdp_<env>`.
Rollback: remove the entries and apply (the schema must be empty, or the
mdp pipeline deleted first).
