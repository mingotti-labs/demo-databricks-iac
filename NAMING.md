# Naming conventions — demo-databricks-iac

## Cloud resources

- S3 buckets: `hoe-mdp-<env>` (`hoe-mdp-dev`, `hoe-mdp-tst`, `hoe-mdp-prd`) — one
  per environment catalog.
- Unity Catalog catalogs: `mdp_<env>` (`mdp_dev`, `mdp_tst`, `mdp_prd`).

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
