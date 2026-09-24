## 1. Grant update

- [x] 1.1 Added `airroi_scope_name` output to
      `modules/databricks-secret-scopes/outputs.tf`
- [x] 1.2 Added `databricks_secret_acl.cicd_airroi_read` (READ, CI/CD SP)
      in `deployment/free_workspace/main.tf`
- [x] 1.3 `terraform plan` reviewed — exactly 1 to add, 0 to change, 0 to
      destroy, as expected

## 2. Apply and verify

- [x] 2.1 Applied — `databricks_secret_acl.cicd_airroi_read` created;
      `databricks secrets list-acls airroi` confirms the CI/CD SP now has
      `READ` alongside the human account's `MANAGE`
- [x] 2.2 Re-ran the CI/CD SP's `prd` AirROI ingestion pipeline that
      originally failed on `dbutils.secrets.get` — both raw pipelines
      `COMPLETED` (`market_summary_raw`: 4 rows, `market_metrics_all_raw`:
      48 rows), both SCD2 pipelines `COMPLETED` (4/48 rows, matching raw
      exactly), and `verify_airroi_market_summary_pattern` — all 4 tasks
      `SUCCESS`

## 3. Documentation

- [x] 3.1 Added a note to this repo's CLAUDE.md ("Secret scopes" section):
      AirROI is the first source needing an explicit CI/CD SP secret-scope
      grant, confirmed via a real `prd` run failure
