## Purpose

Populates Databricks secret scopes with source-database credentials so notebooks and jobs can connect without hardcoded secrets.

## ADDED Requirements

### Requirement: Neon secret scope
A Databricks secret scope named `neon-postgres` SHALL exist containing the keys `host`, `database_name`, `role_name`, and `password`.

#### Scenario: Neon scope populated
- **WHEN** `databricks secrets list-scopes` is run after apply
- **THEN** `neon-postgres` is listed and contains `host`, `database_name`, `role_name`, and `password`

### Requirement: Atlas secret scope
A Databricks secret scope named `atlas-mongodb` SHALL exist containing the keys `connection_string`, `username`, and `password`.

#### Scenario: Atlas scope populated
- **WHEN** `databricks secrets list-scopes` is run after apply
- **THEN** `atlas-mongodb` is listed and contains `connection_string`, `username`, and `password`

### Requirement: Secrets sourced from Terraform outputs only
All secret values SHALL be sourced from Terraform outputs of the source-databases module. No credentials SHALL be hardcoded or stored in version-controlled files.

#### Scenario: No credentials in version control
- **WHEN** the repository is inspected for committed files
- **THEN** no file contains a literal Neon or Atlas credential value; all values trace back to source-databases module outputs

### Requirement: Secret scope accessibility
Secret scopes SHALL be accessible from within the Databricks workspace to notebooks and jobs with appropriate permissions.

#### Scenario: Notebook reads a secret
- **WHEN** a notebook or job with permission on the scope calls `dbutils.secrets.get`
- **THEN** it retrieves the corresponding secret value from `neon-postgres` or `atlas-mongodb`
