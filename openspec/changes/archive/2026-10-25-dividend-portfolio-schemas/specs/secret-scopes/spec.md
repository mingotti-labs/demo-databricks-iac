## ADDED Requirements

### Requirement: FMP secret scope
A Databricks secret scope named `fmp` SHALL exist containing the key
`api_key`, the user's Financial Modeling Prep key, sourced from the
`sensitive` Terraform variable `fmp_api_key` set directly in the HCP Terraform
workspace and never committed.

#### Scenario: FMP scope populated
- **WHEN** `databricks secrets list-secrets fmp` is run after apply
- **THEN** it lists `api_key` (value not displayed)

### Requirement: FRED secret scope
A Databricks secret scope named `fred` SHALL exist containing the key
`api_key`, the user's FRED API key, sourced from the `sensitive` Terraform
variable `fred_api_key` set directly in the HCP Terraform workspace and never
committed.

#### Scenario: FRED scope populated
- **WHEN** `databricks secrets list-secrets fred` is run after apply
- **THEN** it lists `api_key` (value not displayed)

## MODIFIED Requirements

### Requirement: The CI/CD principal reads the scopes that code reads at runtime
The CI/CD service principal SHALL hold `READ` on every secret scope that
pipeline, job or notebook code reads with `dbutils.secrets.get()` at runtime. A
scope that only backs a Terraform-managed UC Connection does not need the grant.
Today these are `airroi`, `neon-postgres`, `fmp` and `fred`.

#### Scenario: Neon scope readable by the principal
- **WHEN** `databricks secrets list-acls neon-postgres` is run after apply
- **THEN** the CI/CD service principal is listed with `READ`

#### Scenario: A job reads Neon credentials as the principal
- **WHEN** a job run as the CI/CD service principal calls
  `dbutils.secrets.get("neon-postgres", "host")`
- **THEN** it returns the secret instead of failing with `PERMISSION_DENIED`

#### Scenario: FMP and FRED scopes readable by the principal
- **WHEN** `databricks secrets list-acls fmp` and `databricks secrets list-acls fred`
  are run after apply
- **THEN** the CI/CD service principal is listed with `READ` on both
