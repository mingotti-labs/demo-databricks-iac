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

## Workflow

@CONTRIBUTING.md

Non-trivial changes go through OpenSpec first: propose (`openspec change new <name>`),
agree the spec, implement, archive. See `openspec/` and each change's `design.md` for
the decision record behind what's built.

## Guardrails — never do without explicit confirmation

- No account-level Terraform resources (Free Edition scope is workspace-level only)
- No destructive `terraform apply`/`destroy` against real state without walking through
  the plan output and getting explicit go-ahead first
- No secrets committed — sensitive variables live in the HCP Terraform workspace
  variable set only, never in a `.tfvars` file (see `.gitignore`)
