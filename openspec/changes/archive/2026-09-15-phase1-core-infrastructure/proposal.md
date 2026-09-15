## Why

The platform has no infrastructure yet — no object storage, no source databases, no Unity Catalog structure, and no secret scopes. Everything downstream (ingestion, modeling, ML, GenAI) depends on these foundations. This change provisions the full platform skeleton in one Terraform apply.

## What Changes

- New S3 bucket (`hoe-mdp-dev`) with versioning enabled and an IAM role for Databricks to assume
- New Neon Postgres project (free-tier serverless, replaces AWS RDS) as the relational source database
- New MongoDB Atlas M0 cluster as the document source database
- Unity Catalog storage credential and external location wired to the S3 bucket via the IAM role
- Unity Catalog catalogs `mdp_dev`, `mdp_tst`, `mdp_prd` with bronze and gold schemas per source
- Secret scopes `neon-postgres` and `atlas-mongodb` populated with connection credentials
- HCP Terraform remote backend for state storage and locking (already configured; this change populates the first real state)

## Capabilities

### New Capabilities

- `cloud-storage`: S3 bucket and IAM role — object storage for Unity Catalog external location
- `unity-catalog`: Storage credential, external location, catalogs (`mdp_dev`, `mdp_tst`, `mdp_prd`), and schemas (bronze/gold per source)
- `source-databases`: Neon Postgres project and MongoDB Atlas M0 cluster
- `secret-scopes`: Databricks secret scopes for Neon and Atlas credentials

### Modified Capabilities

## Impact

- Creates all foundational cloud and Databricks resources; no existing resources are modified
- Requires a two-pass `terraform apply` for the Unity Catalog storage credential: first pass creates the IAM role and storage credential (to obtain the `external_id`), second pass hardens the IAM trust policy with that `external_id`
- Sensitive credentials (AWS keys, Databricks token, Neon API key, Atlas keys) managed exclusively in HCP Terraform variable sets — never touch the filesystem or git
- Non-sensitive variables in `envs/dev/dev.tfvars` (gitignored); `dev.tfvars.example` committed as template
