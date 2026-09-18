## MODIFIED Requirements

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
