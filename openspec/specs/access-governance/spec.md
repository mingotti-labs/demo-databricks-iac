# access-governance Specification

## Purpose
TBD - created by archiving change phase1-access-governance. Update Purpose after archive.

## Requirements

### Requirement: Access Groups per catalog (reserved, not yet functional)
One Access Group SHALL exist per environment catalog, named `AG Catalog <name> READ`.
These groups do NOT currently hold a Unity Catalog grant: UC grants resolve
principals against account-level identities, and Free Edition's API only allows
Terraform to create workspace-level groups (account-level API returns `Not Found`).
Granting a workspace-level group a UC privilege fails with
`Could not find principal with name ...`, confirmed empirically via direct CLI calls
against both a newly created group and a long-established one. The groups are kept as
a structural placeholder for a future account-level migration, not as a working
access mechanism today.

#### Scenario: Access Groups present, ungranted
- **WHEN** the access-governance resources are applied
- **THEN** `AG Catalog mdp_dev READ`, `AG Catalog mdp_tst READ`, and
  `AG Catalog mdp_prd READ` all exist, and none of the three has any Unity Catalog
  grant on its corresponding catalog

### Requirement: FG Data Ops membership in each Access Group (structural)
`FG Data Ops` SHALL be a member of all three Access Groups, reflecting the intended
future shape (functional groups gain catalog access via Access Group membership) even
though membership alone does not currently confer any real privilege.

#### Scenario: Membership present
- **WHEN** `databricks groups get` is run on each of the three Access Groups
- **THEN** `FG Data Ops` is listed as a member of all three

### Requirement: Catalog access via direct grant, for now
Until Access Groups are usable (requires an account-level group, out of reach without
account-level API access on Free Edition), catalog read access SHALL be granted
directly to the principal that needs it, as established in `phase1-identity-governance`.

#### Scenario: CI/CD service principal has real catalog access
- **WHEN** `databricks grants get catalog <name>` is run on any of the three catalogs
- **THEN** the CI/CD service principal's `application_id` (not an Access Group) is
  listed with `USE_CATALOG`, and a job it deploys that runs `USE CATALOG` succeeds
