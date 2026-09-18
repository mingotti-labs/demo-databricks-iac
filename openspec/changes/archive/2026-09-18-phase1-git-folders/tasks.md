## 1. Module

- [x] 1.1 Create `modules/databricks-git-repo/` with `url` (required), `path`
      (required — no default, forces every call site to be explicit) inputs and a
      `databricks_repo` resource — `terraform validate` passed
- [x] 1.2 Output `workspace_path`

## 2. Root composition

- [x] 2.1 Add `module "git_repo_iac"` and `module "git_repo_mdp"` — first attempt
      used `path = "/Repos/<repo-name>"` (2 path components) and failed at plan
      time with an exact provider error: `should have 3 components
      (/Repos/<directory>/<repo>), got 2`. Fixed to `/Repos/Shared/<repo-name>`
      (Databricks' own convention for shared, non-personal content) — `terraform
      plan` then showed exactly 2 resources to create

## 3. Apply and verify

- [x] 3.1 Apply — 2 added, 0 changed, 0 destroyed
- [x] 3.2 Confirm both Git Folders exist at the correct path — verified via
      `databricks workspace list /Repos/Shared`: both
      `/Repos/Shared/demo-databricks-iac` and `/Repos/Shared/demo-databricks-mdp`
      listed. `demo-databricks-iac` referencing itself caused no issue, confirmed
      directly (not assumed) — same as the earlier CLI-based attempt
