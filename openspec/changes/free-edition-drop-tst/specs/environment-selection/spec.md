## ADDED Requirements

### Requirement: Environments come from one map
Each deployment root SHALL provision its per-environment resources (bucket,
storage credential, external location, catalog, schemas, volumes, grants) only
for the keys of its `environments` variable, and no resource SHALL be
conditional on an edition name.

#### Scenario: Free workspace provisions two environments
- **WHEN** the `free_workspace` root is planned with its default `environments`
- **THEN** only `dev` and `prd` catalogs, buckets and external locations are in the plan

#### Scenario: Removing an environment removes its resources
- **WHEN** a key is removed from `environments`
- **THEN** the plan destroys that environment's resources and changes no other environment's

### Requirement: Free Edition has no tst environment
The `free_workspace` root SHALL default `environments` to `dev` and `prd`,
because a Free Edition metastore is capped at 500 tables and each environment
multiplies every table.

#### Scenario: Default environments
- **WHEN** `deployment/free_workspace/variables.tf` is read
- **THEN** the `environments` default contains `dev` and `prd` and no `tst`
