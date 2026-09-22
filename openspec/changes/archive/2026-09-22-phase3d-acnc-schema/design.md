## Context

See proposal.md - Why. Fourth source system, same `_raw`+`_publish` pattern
established by `phase3b-bronze-schema-simplification` and already applied
to `bronze_neon`/`bronze_clickstream`/`bronze_ungm`.

## Goals / Non-Goals

**Goals:**
- Give the ACNC Charity Register the same schema shape every other source has

**Non-Goals:**
- Any credential/connection/volume infrastructure — data.gov.au's CKAN
  Data API needs none (public, no auth, no token of any kind — confirmed
  via a real `datastore_search` request before this change was written)

## Decisions

**Schema only, nothing else.**
Same reasoning as `phase3c-ungm-schema`: the source needs no credential
anchor, so this stays the smallest kind of source-system onboarding change.

## Risks / Trade-offs

None — purely additive, no credentials or external dependencies involved.

## Migration Plan

Additive only. Apply, confirm the two new schemas exist per environment via
`databricks schemas list`, then hand off to the `demo-databricks-mdp` change
that writes into them. Rollback: destroy the schemas — nothing consumes
them until that change is built.
