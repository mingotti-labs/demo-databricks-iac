## Context

See proposal.md - Why. Third source system, same `_raw`+`_publish` pattern
established by `phase3b-bronze-schema-simplification` and already applied
to `bronze_neon`/`bronze_clickstream`.

## Goals / Non-Goals

**Goals:**
- Give UNGM/UNSPSC the same schema shape every other source has

**Non-Goals:**
- Any credential/connection/volume infrastructure — the UNSPSC endpoint
  being built now needs none (public, no auth). If a future UNGM endpoint
  needs auth, that's a separate change adding a secret scope when it's
  actually needed, not provisioned speculatively here (per direct
  instruction — a placeholder in code is free, a placeholder secret scope
  with nothing to protect is not)

## Decisions

**Schema only, nothing else.**
Every other source system's first iac change also provisioned some kind of
credential anchor (`neon_dev` UC Connection for 3a, `s3_clickstream_raw`
volume for 3b). UNGM's public API needs neither — the ingestion pipeline
authenticates to nothing, reads over plain HTTPS. This change is
deliberately the smallest of the three source-system-onboarding changes so
far, reflecting that the source genuinely needs less infrastructure, not an
oversight.

## Risks / Trade-offs

None — purely additive, no credentials or external dependencies involved.

## Migration Plan

Additive only. Apply, confirm the two new schemas exist per environment via
`databricks schemas list`, then hand off to the `demo-databricks-mdp` change
that writes into them. Rollback: destroy the schemas — nothing consumes
them until that change is built.
