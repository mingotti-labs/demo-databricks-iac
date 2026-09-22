# CLAUDE.md — demo-databricks-iac

Conventions for AI-assisted development on this Terraform infrastructure repo.
This file captures repo-specific decisions; general coding standards are in the
global ~/.claude/CLAUDE.md.

## Platform context

- Databricks Free Edition (serverless compute only, single workspace)
- One Databricks metastore serving all environment catalogs
- AWS-hosted: object storage, Neon Postgres, MongoDB Atlas
- Remote state: HCP Terraform (org `hands-on-essential-mingotti`, workspace
  `demo-databricks-iac`)

## Repository structure

- `modules/`: shared, single-instance Terraform modules (one bucket per call, one
  catalog per call, etc.) — multiplicity is composed at the root, not inside a module.
- `deployment/free_workspace/`: the one real deployment root today (Free Edition:
  single workspace, serverless-only, no account-level API).
- `deployment/single_workspace/`, `deployment/multiple_workspaces/`: reserved,
  empty (`.gitkeep` only) placeholders for future deployment shapes (a future paid
  single workspace, and the corporate multi-workspace pattern respectively) — do not
  build these out until there's a real need.

## Naming conventions

@NAMING.md

## Identity & groups

Both group axes (naming: see NAMING.md) are Terraform-managed — add members by
editing the relevant module, not the workspace UI:
`modules/databricks-identity-governance/` (functional groups),
`modules/databricks-access-groups/` (Access Groups).

`AG Catalog <name> READ` groups are **currently a reserved placeholder, not a
working grant mechanism** — Unity Catalog grants resolve principals against
account-level identities, and Free Edition's API only lets Terraform create
workspace-level groups, so granting one fails with `Could not find principal with
name ...` (confirmed empirically, not a bug in this repo's code; see the
`phase1-access-governance` change's design.md for the full investigation). Real
catalog access is a direct `databricks_grants` to the principal for now, same
mechanism `phase1-identity-governance` established.

New service principals should NOT be added to the built-in `admins` group without a
specific, evidenced reason (see the `phase1-identity-governance` change's design.md
for why).

### CI/CD service principal pipeline execution

The CI/CD SP needs more than `USE_CATALOG` to actually run a pipeline —
`BROWSE` on the catalog (cluster initialization) and `USE_SCHEMA` +
`CREATE_TABLE` on its target schema (creating/writing its managed table) are
both required, granted across every bronze schema up front
(`databricks_grants.cicd_catalog_use`/`cicd_schema_use`). Both were discovered
via real pipeline run failures, not anticipated — see
`phase3b-cicd-pipeline-grants`'s design.md.

A job/pipeline's execution identity (`run_as_user_name`) is a property of the
resource itself, not of whoever triggers the run — a sufficiently-privileged
human can trigger a CI/CD-SP-owned resource via CLI/API and it still executes
(and fails, or succeeds) under the SP's own permissions. No local
machine-to-machine credentials are needed to run something "as" the SP; just
target that resource's ID directly.

**Deleting a Lakeflow Declarative Pipeline deletes its managed tables by
default** (confirmed via Databricks' own docs — a beta `cascade=false` option
exists to keep them, but its reattachment mechanics aren't well-documented
enough to rely on). This is why the CI/CD SP's dev-prefixed pipeline/job
copies (`[dev svc_cicd_github] ...`) are the canonical, durable ones for this
project — the human-identity dev copies (`[dev handsonessential] ...`) are
disposable personal-iteration artifacts, safe to delete without losing
anything real, and should never be relied on to hold real data.

## Source databases

Naming: see NAMING.md.

- **Neon Postgres** (`modules/neon/`): `main` (stable/production-equivalent data
  line, no rename needed — same as git's `main` not being renamed to "prod") and
  `dev` (forked from `main`, where active development and downstream ingestion
  work happens). The `neon-postgres` secret scope points at **`dev`**, not `main`.
  Neither branch is protected — Neon's free tier doesn't support protected branches
  (`BRANCHES_PROTECTED_LIMIT_EXCEEDED`, confirmed via a real apply attempt); be
  deliberate before any destructive operation against `main`.
- **MongoDB Atlas** (`modules/atlas/`): no branching feature to mirror the Neon
  pattern with, so the naming inconsistency between the two source databases (see
  NAMING.md) is accepted rather than "fixed" to match.

## UC Connections

Naming: see NAMING.md.

- **`neon_dev`** (`modules/databricks-uc-connection-postgres/`): points at Neon's
  `dev` branch. Consumed by `phase3a-lakeflow-connect-neon` in
  `demo-databricks-mdp` — its ingestion pipeline references this connection by
  name. No `sslmode` option — this connection type doesn't support one (confirmed
  via a real apply rejection); Neon negotiates SSL on its own. To verify
  connectivity to any UC Connection, `SHOW SCHEMAS IN CONNECTION <name>` is not
  valid syntax — use a temporary `CREATE FOREIGN CATALOG ... USING CONNECTION`,
  browse it, then drop it (see `phase3a-neon-uc-connection`'s tasks.md for the
  exact commands).

## UC Volumes

Naming: see NAMING.md.

- **`s3_clickstream_raw`** (`modules/databricks-uc-volume/`): one `MANAGED`
  volume per environment, inside that environment's `bronze_clickstream`
  schema. Consumed by `phase3b-clickstream-autoloader` in `demo-databricks-mdp`
  — its Auto Loader pipeline reads synthetic clickstream files from this
  volume's path. Multi-env from the start (unlike `neon_dev`), since the
  source data is entirely synthetic — each environment generates and lands its
  own independent data. Storage reuses each environment's existing bucket (the
  same one backing that catalog's `storage_root`) — no new bucket, storage
  credential, or external location. Whether the CI/CD service principal needs
  an explicit grant to read/write it (beyond the existing catalog-level
  `USE_CATALOG` grant) was left unverified here — see
  `phase3b-clickstream-volume`'s design.md.

## Bronze schema shape

Each source system gets exactly two bronze-family schemas: `bronze_<source>`
(raw, source-faithful landing) and `bronze_<source>_publish` (governed — SCD1/
SCD2 tables, and future row/column security). There is deliberately no
`bronze_<source>_history` schema — Phase 1 reserved one per source
(`bronze_neon_history`, `bronze_atlas_history`) for full change-history/CDC
replay, but both sat empty (confirmed via `databricks tables list` before
removal), and that purpose is now served by `<table>_scd2` tables inside
`_publish` instead — more directly queryable than a raw history table would
have been. See `phase3b-bronze-schema-simplification`'s design.md for the full
reasoning. SCD1/SCD2 tables themselves are built in `demo-databricks-mdp`, not
here — this repo only provisions the schema.

**`bronze_ungm`/`bronze_ungm_publish`** (Phase 3c, UNGM UNSPSC API): the
smallest source-system onboarding so far — the UNGM public API needs no
credential, connection, or volume, just the schema pair. Consumed by an
upcoming `demo-databricks-mdp` change. CI/CD SP schema-level grants
(`USE_SCHEMA`/`CREATE_TABLE`) applied proactively this time, not
discovered via a failure — see "CI/CD service principal pipeline
execution" above.

**`bronze_acnc`/`bronze_acnc_publish`** (Phase 3d, ACNC Charity Register):
same shape as UNGM's — data.gov.au's public CKAN Data API needs no
credential, connection, or volume either, just the schema pair. Consumed
by an upcoming `demo-databricks-mdp` change (a reusable custom PySpark
Data Source connector, not a one-off fetch helper like UNGM's). CI/CD SP
schema-level grants applied proactively, same as UNGM's.

## Workspace Git Folders

Both this repo and `demo-databricks-mdp` are cloned into the Databricks workspace
as Git Folders (`modules/databricks-git-repo/`), at `/Repos/Shared/<repo-name>` —
not a personal `/Repos/<user>/<repo-name>` path (the provider's default if `path`
is left unset). Terraform-managed like everything else here, not the
`databricks repos create` CLI or the workspace UI. Browse/dev convenience only —
no auto-pull-on-push; nothing in either bundle or Terraform pipeline reads from
these paths.

## Workflow

@CONTRIBUTING.md

Non-trivial changes go through OpenSpec first: propose (`openspec change new <name>`),
agree the spec, implement, archive. See `openspec/` and each change's `design.md` for
the decision record behind what's built.

## Running Terraform locally

`environment` and `uc_external_ids` have no persisted value in the HCP
Terraform workspace — they must be passed explicitly on every local
`plan`/`apply` (`-var="environment=dev" -var='uc_external_ids={"dev":"...",
"tst":"...","prd":"..."}'`, current values via `terraform output -json
uc_external_ids`). Omitting `uc_external_ids` doesn't just no-op — it plans to
*strip* the `sts:ExternalId` condition from each environment's IAM trust
policy (reverting to the variable's empty default), a real security downgrade
that looked like unrelated drift the first time it was hit. Always read the
full plan output for unexpected changes/destroys before applying, even when
the change you're making is purely additive.

## Guardrails — never do without explicit confirmation

- No account-level Terraform resources (Free Edition scope is workspace-level only)
- No destructive `terraform apply`/`destroy` against real state without walking through
  the plan output and getting explicit go-ahead first
- No secrets committed — sensitive variables live in the HCP Terraform workspace
  variable set only, never in a `.tfvars` file (see `.gitignore`)
