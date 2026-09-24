# secret-scopes Specification

## Purpose

Populates Databricks secret scopes with source-database credentials so notebooks and jobs can connect without hardcoded secrets.

## Requirements

### Requirement: Neon secret scope
A Databricks secret scope named `neon-postgres` SHALL exist containing the keys
`host`, `database_name`, `role_name`, and `password`, sourced from the Neon `dev`
branch (not `main`) — active development and downstream ingestion work SHALL target
`dev`, leaving `main` as the untouched stable/production-equivalent data line.

#### Scenario: Neon scope populated
- **WHEN** `databricks secrets list-scopes` is run after apply
- **THEN** `neon-postgres` is listed and contains `host`, `database_name`,
  `role_name`, and `password`, resolving to the Neon `dev` branch's connection
  details, not `main`'s

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

### Requirement: AirROI secret scope
A Databricks secret scope named `airroi` SHALL exist containing the key
`api_key`, sourced from a `sensitive` Terraform variable set directly in
the HCP Terraform workspace — the project's first real (non-placeholder)
third-party API credential, unlike UNGM's documented-but-unprovisioned
placeholder. The CI/CD service principal SHALL have an explicit `READ`
grant on this scope, since it is the first secret scope actually read by
pipeline code (`dbutils.secrets.get`) at runtime, not just backing a
Terraform-managed UC Connection.

#### Scenario: AirROI scope populated
- **WHEN** `databricks secrets list-scopes` is run after apply
- **THEN** `airroi` is listed and `databricks secrets list-secrets airroi`
  shows it contains `api_key`

#### Scenario: CI/CD SP can read the scope
- **WHEN** `databricks secrets list-acls airroi` is run after apply
- **THEN** the CI/CD SP's client ID is listed with `READ` permission,
  alongside the human account's `MANAGE`

#### Scenario: CI/CD-SP-owned pipeline reads the secret successfully
- **WHEN** a Lakeflow pipeline owned by the CI/CD SP calls
  `dbutils.secrets.get("airroi", "api_key")`
- **THEN** the call succeeds and returns the real API key, not a
  `PERMISSION_DENIED`/`SecretManagerClient` error
