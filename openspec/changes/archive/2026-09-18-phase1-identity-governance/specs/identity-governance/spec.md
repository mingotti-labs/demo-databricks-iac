## ADDED Requirements

### Requirement: Functional groups
Three Databricks groups SHALL exist: `FG Platform Engineering`, `FG Data Engineering`,
and `FG Data Ops`.

#### Scenario: Groups present
- **WHEN** `databricks groups list` is run after apply
- **THEN** `FG Platform Engineering`, `FG Data Engineering`, and `FG Data Ops` are all
  listed

#### Scenario: Platform Engineering and Data Engineering start empty
- **WHEN** `databricks groups get "FG Platform Engineering"` and
  `databricks groups get "FG Data Engineering"` are run after apply
- **THEN** neither group has any members

### Requirement: CI/CD service principal
A service principal SHALL exist for CI/CD bundle deployment, with an OAuth client
secret Terraform generates and exposes as a sensitive output, and the
`workspace_access` entitlement (the minimum of the three that `bundle deploy` requires
— `databricks-sql-access`, `workspace-access`, or `workspace-consume` — determined
empirically, not guessed).

#### Scenario: Service principal created
- **WHEN** the identity-governance resources are applied
- **THEN** a service principal named `svc-cicd-github` exists with `workspace_access =
  true` and all other entitlement flags `false`, and `terraform output` exposes its
  `cicd_client_id` (plain) and `cicd_client_secret` (sensitive)

### Requirement: CI/CD service principal catalog access
The CI/CD service principal SHALL have `USE_CATALOG` on each of the three environment
catalogs (`mdp_dev`, `mdp_tst`, `mdp_prd`) and no broader Unity Catalog privilege,
granted via Terraform (`databricks_grants`, composed at the root from the
`aws_s3`/`unity_catalog`/`identity_governance` modules' outputs).

#### Scenario: Bundle-deployed job runs successfully
- **WHEN** a job deployed by the CI/CD service principal that runs `USE CATALOG` on
  its target's catalog is executed
- **THEN** the run completes successfully instead of failing with
  `PERMISSION_DENIED: User does not have USE CATALOG on Catalog '<name>'`

### Requirement: CI/CD service principal group membership
The CI/CD service principal and the human account that manages it
(`handsonessential@gmail.com`) SHALL be members of `FG Data Ops` only. Neither SHALL
be a member of the built-in `admins` group, and `FG Data Ops` SHALL NOT be nested
under `admins`.

#### Scenario: Membership scoped to Data Ops
- **WHEN** `databricks groups get "FG Data Ops"` is run after apply
- **THEN** both the CI/CD service principal and `handsonessential@gmail.com` are
  listed as members, and neither is a member of `FG Platform Engineering` or
  `FG Data Engineering`

#### Scenario: No admin grant
- **WHEN** the `admins` group's membership is inspected after apply
- **THEN** neither the CI/CD service principal, `FG Data Ops`, nor
  `handsonessential@gmail.com` was added to it by this change
