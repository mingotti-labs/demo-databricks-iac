## MODIFIED Requirements

### Requirement: Neon Postgres project
A Neon Postgres project named `mdp` SHALL exist (free-tier serverless, region
`ap-southeast-2` or nearest available) with a database and a role scoped to that
project. The project SHALL have two branches: `main` (serving as the
stable/production-equivalent data line, matching the git convention of the same
name) and `dev` (forked from `main`, where active development and downstream
ingestion work happens). Neither branch SHALL be assumed protected — Neon's free
tier does not support protected branches.

#### Scenario: Neon project provisioned
- **WHEN** the neon module is applied
- **THEN** a Neon project named `mdp` exists with a `main` branch and a `dev` branch
  (forked from `main`), each with its own database, role, and compute endpoint, and
  `terraform plan` shows the corresponding resources created

### Requirement: Neon outputs for downstream wiring
Connection details for both branches SHALL be available as Terraform outputs:
`main_host`/`main_database_name`/`main_role_name`/`main_password` for the `main`
branch, and `dev_host`/`dev_database_name`/`dev_role_name`/`dev_password` for the
`dev` branch, for use by the secret-scopes module.

#### Scenario: Neon outputs available
- **WHEN** `terraform plan` runs with the neon module called from root
- **THEN** `main_host`, `main_database_name`, `main_role_name`, `main_password`,
  `dev_host`, `dev_database_name`, `dev_role_name`, and `dev_password` all appear as
  module outputs
