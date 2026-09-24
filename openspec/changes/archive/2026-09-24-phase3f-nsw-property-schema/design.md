## Context

See proposal.md - Why. Fifth source system, same `_raw`+`_publish` pattern
established by `phase3b-bronze-schema-simplification` and already applied
to `bronze_neon`/`bronze_clickstream`/`bronze_ungm`/`bronze_acnc`.

## Goals / Non-Goals

**Goals:**
- Give the NSW property source the same schema shape every other source has

**Non-Goals:**
- Any credential/connection/volume infrastructure — the NSW ArcGIS
  FeatureServer layer being built now needs none (public, no auth,
  confirmed via a real query before this change was written)

## Decisions

**Schema only, nothing else, `CREATE_MATERIALIZED_VIEW` included from the
start this time.**
Same reasoning as `phase3c-ungm-schema`/`phase3d-acnc-schema`: the source
needs no credential anchor. Unlike those two, this proposal includes
`CREATE_MATERIALIZED_VIEW` in the CI/CD schema grant from the outset — that
privilege gap was only discovered reactively during ACNC's build
(`phase3d-cicd-materialized-view-grant`), and this pipeline is also
expected to use a Materialized View, so there's no reason to repeat that
discovery a third time.

## Risks / Trade-offs

None — purely additive, no credentials or external dependencies involved.

## Migration Plan

Additive only. Apply, confirm the two new schemas exist per environment via
`databricks schemas list`, then hand off to the `demo-databricks-mdp` change
that writes into them. Rollback: destroy the schemas — nothing consumes
them until that change is built.
