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
