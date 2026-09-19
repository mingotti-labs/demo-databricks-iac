## Context

See proposal.md - Why. This surfaced while recovering from an incident: the
human-identity dev copy of `neon_ecommerce_ingestion` (a leftover from before
this project settled on treating CI/CD-SP-owned resources as canonical) was
deleted during an earlier cleanup. Per Databricks' own docs, deleting a
pipeline deletes its managed Streaming Tables/Materialized Views by default —
which is exactly what happened to `bronze_neon.*_raw`. The Neon Postgres
*source* data was never touched and remained fully intact throughout.

A key fact discovered along the way: a job/pipeline's execution identity
(`run_as_user_name`) is a property of the resource itself, not of whoever
triggers the run via API/UI — confirmed empirically (triggering the CI/CD
SP-owned pipeline as `handsonessential@gmail.com` still executed, and failed,
under the SP's own permissions, not the triggering human's). This means any
sufficiently-privileged human can trigger a CI/CD-SP-owned resource and have
it execute durably under the SP's identity, without needing local
machine-to-machine (M2M) credentials configured.

## Goals / Non-Goals

**Goals:**
- The CI/CD SP's dev pipeline copies can actually run successfully, so they
  can be treated as the canonical, durable data going forward (not the
  human-identity dev copies, which remain useful only for quick interactive
  iteration and are safe to delete without losing anything real)
- Grant schema-level access across every bronze schema up front, since every
  ingestion/SCD pipeline this project builds will need the same access on its
  own target schema — avoid rediscovering this once per schema/pipeline

**Non-Goals:**
- Setting up local M2M authentication as the CI/CD SP — unnecessary, since
  triggering the SP-owned resource directly (as any sufficiently-privileged
  human) already executes under the SP's identity
- Extending CI/CD (`pr.yml`/`main.yml`) to automatically run jobs/pipelines
  after deploy — a real, separate idea raised in discussion, deliberately
  deferred to its own change given the Free Edition serverless quota already
  hit once today; automatic runs on every PR would make that worse, not
  better, without more thought on scope/triggering
- Relying on `cascade=false` pipeline deletion (keeps tables on delete) as a
  safety net — it's a beta feature whose reattachment mechanics aren't
  documented well enough to trust without direct verification against real
  data, which isn't worth the risk to attempt here

## Decisions

**Grant `BROWSE` and `USE_SCHEMA`/`CREATE_TABLE` up front across all bronze
schemas, not just `bronze_neon`.**
Both gaps were discovered against `neon_ecommerce_ingestion` specifically, but
neither is Neon-specific — every pipeline this project runs as the CI/CD SP
(the upcoming Neon SCD pipeline, the clickstream Auto Loader variants, the
clickstream SCD1 pipeline) will hit the identical two errors against its own
target schema. Fixing it once, broadly, is cheaper than four more rounds of
"deploy, fail, diagnose, fix."

**Human-identity dev pipeline copies are not restored or relied upon.**
`[dev handsonessential] neon-ecommerce-ingestion-dev` still exists (freshly
recreated, empty) from the earlier `bundle deploy` — left as-is, understood
now as a disposable personal-iteration copy, not a source of truth. Nothing in
this project should query or depend on it going forward; the CI/CD SP's copy
(`[dev svc_cicd_github] neon-ecommerce-ingestion-dev`) is canonical for dev.

## Risks / Trade-offs

- [Granting `CREATE_TABLE` broadly across all bronze schemas lets the CI/CD SP
  create tables beyond what any single pipeline currently defines] →
  Mitigation: acceptable for this project's scope (a personal demo platform,
  single operator) — the SP only ever runs what this repo's bundle defines,
  and every pipeline resource is itself reviewed via PR before it can create
  anything.

## Migration Plan

Additive only (grants), no destructive changes. Apply, then verify by
triggering `neon_ecommerce_ingestion`'s CI/CD-SP-owned copy directly — a real
run succeeding is the actual proof, not `terraform apply` succeeding alone.
Rollback: remove the added privileges; nothing depends on them existing beyond
the pipelines that need them to function.
