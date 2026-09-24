## MODIFIED Requirements

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
