## MODIFIED Requirements

### Requirement: The CI/CD principal reads the scopes that code reads at runtime
The CI/CD service principal SHALL hold `READ` on every secret scope that
pipeline, job or notebook code reads with `dbutils.secrets.get()` at runtime. A
scope that only backs a Terraform-managed UC Connection does not need the grant.
Today these are `airroi`, `neon-postgres` and `fred`.

#### Scenario: Neon scope readable by the principal
- **WHEN** `databricks secrets list-acls neon-postgres` is run after apply
- **THEN** the CI/CD service principal is listed with `READ`

#### Scenario: A job reads Neon credentials as the principal
- **WHEN** a job run as the CI/CD service principal calls
  `dbutils.secrets.get("neon-postgres", "host")`
- **THEN** it returns the secret instead of failing with `PERMISSION_DENIED`

#### Scenario: FMP and FRED scopes readable by the principal
- **WHEN** `databricks secrets list-acls fred` is run after apply
- **THEN** the CI/CD service principal is listed with `READ`, and
  `databricks secrets list-scopes` shows no `fmp` scope (removed after the
  FMP probe; the scenario keeps its name so the archive replaces it)

## REMOVED Requirements

### Requirement: FMP secret scope
**Reason**: FMP was dropped after its probe (its free plan refuses the S&P 500
list and covers only a sample of symbols); no code reads the scope.
**Migration**: none; the user deletes the unused `fmp_api_key` workspace
variable in HCP Terraform after the apply.
