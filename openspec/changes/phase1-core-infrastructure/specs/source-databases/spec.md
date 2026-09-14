## ADDED Requirements

- A Neon Postgres project exists (free-tier serverless, region `ap-southeast-2` or nearest available)
- The Neon project has a database and a role scoped to that project
- Neon connection details (host, database name, role name, password) are available as Terraform outputs for use by the secret-scopes module
- A MongoDB Atlas project exists under the configured Atlas organisation
- The Atlas project contains one M0 (free-tier) cluster
- An Atlas database user exists scoped to the project with read/write access
- Atlas connection details (connection string, username, password) are available as Terraform outputs for use by the secret-scopes module
