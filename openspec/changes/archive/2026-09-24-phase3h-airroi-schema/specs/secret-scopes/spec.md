## ADDED Requirements

### Requirement: AirROI secret scope
A Databricks secret scope named `airroi` SHALL exist containing the key
`api_key`, sourced from a `sensitive` Terraform variable set directly in
the HCP Terraform workspace — the project's first real (non-placeholder)
third-party API credential, unlike UNGM's documented-but-unprovisioned
placeholder.

#### Scenario: AirROI scope populated
- **WHEN** `databricks secrets list-scopes` is run after apply
- **THEN** `airroi` is listed and `databricks secrets list-secrets airroi`
  shows it contains `api_key`
