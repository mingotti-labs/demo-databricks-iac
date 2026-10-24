# Naming conventions — demo-databricks-iac

## Cloud resources

- S3 buckets: `hoe-mdp-<env>` (`hoe-mdp-dev`, `hoe-mdp-prd`; `hoe-mdp-tst` in the
  three-environment reference) — one per environment catalog.
- Unity Catalog catalogs: `mdp_<env>` (`mdp_dev`, `mdp_prd`; `mdp_tst` in the
  three-environment reference).

## Identity & groups

Two group axes:

- **`FG <Name>`** — functional groups, modeling *what function a principal
  serves*: `FG Platform Engineering`, `FG Data Engineering`, `FG Data Ops`.
- **`AG Catalog <name> READ`** — Access Groups, modeling *what a principal can
  access*: one per environment catalog.

See CLAUDE.md's "Identity & groups" section for current behavior and limitations
of each — this file covers naming only.

## Source databases

- Neon Postgres project: `mdp` (not per-environment — one instance, git-style
  branches instead of separate projects: `main`, `dev`).
- MongoDB Atlas project: `mdp-<env>` (currently `mdp-dev` only — accepted
  inconsistency with Neon's naming; see CLAUDE.md).

## UC Connections

- `<source>_<branch-or-env>` — e.g. `neon_dev` (Neon's `dev` branch).

## UC Volumes

- `<service>_raw` — e.g. `s3_raw`. One volume per
  source system, living inside that source's own `bronze_<source>` schema, which
  already names the source (volume names only need to be unique within a schema,
  so `mdp_dev.bronze_portfolio.s3_raw` and another source's `s3_raw` never clash).
  The one exception is `s3_clickstream_raw`, kept so the volume is not recreated
  (a rename could lose its files). Volumes are not
  shared across source systems, so UC volume-level grants (`READ VOLUME` /
  `WRITE VOLUME`) stay scoped to one source at a time (same reasoning as one
  schema per source system). Volume storage reuses the environment's existing
  bucket (the same one backing the catalog's `storage_root`/external location)
  — no new bucket, storage credential, or external location per source system.

## Pattern schemas

- `pattern_<layer>` (`pattern_bronze`, `pattern_bronze_publish`, ...) in the dev
  catalog only: output of pattern-only implementations. `<layer>` is a schema
  family from the design-pattern register. Never created in `tst`/`prd`.
