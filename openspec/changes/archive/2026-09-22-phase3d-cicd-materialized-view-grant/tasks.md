## 1. Grant update

- [x] 1.1 Added `CREATE_MATERIALIZED_VIEW` to the CI/CD SP's grant block in
      `databricks_grants.cicd_schema_use` (`deployment/free_workspace/main.tf`)
- [x] 1.2 `terraform plan` showed exactly 0 to add, 30 to change (in
      place), 0 to destroy -- 30, not 18, since the writable-schema list
      has grown to 10 schemas (bronze_ungm/_publish, bronze_acnc/_publish
      added since `phase3b-cicd-pipeline-grants`), not 6

## 2. Apply and verify

- [x] 2.1 Applied — 30 changed
- [x] 2.2 Re-ran the CI/CD SP's `acnc_charity_register_ingestion` pipeline
      update that originally failed with `PERMISSION_DENIED: User does not
      have CREATE MATERIALIZED VIEW on Schema 'mdp_dev.bronze_acnc'` —
      `COMPLETED`. Also ran the SCD modeling pipeline and the verification
      job under the SP — both `COMPLETED`/`SUCCESS`; row counts confirmed
      identical to the earlier human-identity run (raw=500,
      quarantine=11, scd1=scd2=489)

## 3. Documentation

- [x] 3.1 Added a note to this repo's CLAUDE.md ("CI/CD service principal
      pipeline execution" section): `CREATE_MATERIALIZED_VIEW` is a
      separate UC privilege from `CREATE_TABLE`, confirmed via a real
      failure; Streaming Tables have no equivalent separate privilege
