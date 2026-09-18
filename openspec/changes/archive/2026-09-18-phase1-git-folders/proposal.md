## Why

Both repos should be browsable inside the Databricks workspace (Git Folders), so
notebooks and code can be inspected/edited in-workspace against the same source of
truth as GitHub. Initially added imperatively via `databricks repos create` (CLI) —
inconsistent with every other workspace object this project provisions, all of
which go through Terraform in this repo. Reverted and redone as code, and at the
correct shared location (`/Repos/Shared/<name>`, not a personal `/Repos/<user>/<name>`
path).

## What Changes

- New module `modules/databricks-git-repo/`: one `databricks_repo` per call
  (single-instance, matching this repo's module convention)
- Root composes two instances: this repo (`demo-databricks-iac`) and
  `demo-databricks-mdp`, each at a top-level shared path (`/Repos/Shared/<repo-name>`)

## Cross-repo dependencies

None — this only adds read/browse access to both repos' existing GitHub sources,
doesn't touch anything `demo-databricks-mdp` provisions or consumes.

## Impact

- Adds two `databricks_repo` resources (inside the new module) to Terraform state
- Both repos are public (per the roadmap's Phase 0 scaffolding), so no
  `git_credential_id` is needed to clone either
- Risk specifically called out and tested: `demo-databricks-iac` referencing
  itself as a Git Folder inside the workspace it provisions. No actual loop risk —
  Git Folders is a passive browse/sync feature, doesn't execute anything on its
  own — but tested deliberately (CLI first, now via Terraform) rather than assumed
  safe.
