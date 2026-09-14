## ADDED Requirements

- A Databricks secret scope named `neon-postgres` exists containing: `host`, `database_name`, `role_name`, `password`
- A Databricks secret scope named `atlas-mongodb` exists containing: `connection_string`, `username`, `password`
- All secret values are sourced from Terraform outputs of the source-databases module — no credentials are hardcoded or stored in version-controlled files
- Secret scopes are accessible from within the Databricks workspace to notebooks and jobs with appropriate permissions
