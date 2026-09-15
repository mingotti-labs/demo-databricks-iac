# source-databases Specification

## Purpose

Provisions the platform's relational and document source databases (Neon Postgres and MongoDB Atlas) as the origin systems for downstream ingestion.

## Requirements

### Requirement: Neon Postgres project
A Neon Postgres project SHALL exist (free-tier serverless, region `ap-southeast-2` or nearest available) with a database and a role scoped to that project.

#### Scenario: Neon project provisioned
- **WHEN** the neon module is applied
- **THEN** a Neon project, database, and role exist, and `terraform plan` shows the corresponding resources created

### Requirement: Neon outputs for downstream wiring
Neon connection details (`host`, `database_name`, `role_name`, `password`) SHALL be available as Terraform outputs for use by the secret-scopes module.

#### Scenario: Neon outputs available
- **WHEN** `terraform plan` runs with the neon module called from root
- **THEN** `host`, `database_name`, `role_name`, and `password` appear as module outputs

### Requirement: MongoDB Atlas cluster
A MongoDB Atlas project SHALL exist under the configured Atlas organisation, containing one M0 (free-tier) cluster and a database user scoped to the project with read/write access.

#### Scenario: Atlas cluster provisioned
- **WHEN** the atlas module is applied
- **THEN** an Atlas project, M0 cluster, and database user with read/write access exist, and `terraform plan` shows the corresponding resources created

### Requirement: Atlas outputs for downstream wiring
Atlas connection details (`connection_string`, `username`, `password`) SHALL be available as Terraform outputs for use by the secret-scopes module.

#### Scenario: Atlas outputs available
- **WHEN** `terraform plan` runs with the atlas module called from root
- **THEN** `connection_string`, `username`, and `password` appear as module outputs
