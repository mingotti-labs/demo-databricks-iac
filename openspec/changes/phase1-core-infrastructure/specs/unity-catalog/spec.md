## ADDED Requirements

- A storage credential exists in Unity Catalog using the IAM role ARN from the cloud-storage module; it is the only credential used for S3 access
- An external location exists pointing to the S3 bucket via the storage credential; Databricks can read and write Delta tables at that location
- Three catalogs exist: `mdp_dev`, `mdp_tst`, `mdp_prd`
- Each catalog contains the following schemas:
  - `bronze_neon` — raw Neon Postgres ingestion landing zone
  - `bronze_neon_history` — full history / before-image records for Neon
  - `bronze_neon_publish` — publish-ready view of Neon bronze data
  - `bronze_atlas` — raw MongoDB Atlas ingestion landing zone
  - `bronze_atlas_history` — full history / before-image records for Atlas
  - `bronze_atlas_publish` — publish-ready view of Atlas bronze data
  - `gold_analytics_gateway` — analytics-facing gold layer
  - `gold_integration_gateway` — integration-facing gold layer
  - `gold_ai_gateway` — AI/ML-facing gold layer
- Silver schemas are not created in Phase 1 (domains not yet defined)
- All resources are workspace-level (no account-level Terraform resources; Free Edition constraint)
