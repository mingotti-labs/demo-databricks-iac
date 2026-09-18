## ADDED Requirements

### Requirement: Both repos browsable as workspace Git Folders
Both `demo-databricks-iac` and `demo-databricks-mdp` SHALL be cloned into the
Databricks workspace as Git Folders (`databricks_repo`), each at a top-level
shared path (`/Repos/Shared/<repo-name>`), not a personal-user-folder path.

#### Scenario: Repos present at the correct shared path
- **WHEN** `databricks repos get <id>` is run for each
- **THEN** `path` is `/Repos/Shared/demo-databricks-iac` and `/Repos/Shared/demo-databricks-mdp`
  respectively, and `branch` is `main` for both

### Requirement: Terraform-managed, not CLI-created
Git Folders for both repos SHALL be provisioned via Terraform, not the
`databricks repos create` CLI command or the workspace UI.

#### Scenario: Tracked in Terraform state
- **WHEN** `terraform state list` is run in this repo
- **THEN** it includes both `databricks_repo` resources (inside
  `modules/databricks-git-repo/`)
