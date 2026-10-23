## ADDED Requirements

### Requirement: The CI/CD principal reads the scopes that code reads at runtime
The CI/CD service principal SHALL hold `READ` on every secret scope that
pipeline, job or notebook code reads with `dbutils.secrets.get()` at runtime. A
scope that only backs a Terraform-managed UC Connection does not need the grant.
Today these are `airroi` and `neon-postgres`.

#### Scenario: Neon scope readable by the principal
- **WHEN** `databricks secrets list-acls neon-postgres` is run after apply
- **THEN** the CI/CD service principal is listed with `READ`

#### Scenario: A job reads Neon credentials as the principal
- **WHEN** a job run as the CI/CD service principal calls
  `dbutils.secrets.get("neon-postgres", "host")`
- **THEN** it returns the secret instead of failing with `PERMISSION_DENIED`
