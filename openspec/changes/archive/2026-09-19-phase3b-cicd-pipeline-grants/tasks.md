## 1. Incident diagnosis (before any config change)

- [x] 1.1 Confirmed `bronze_neon` was empty in all three environments
      (`databricks tables list`)
- [x] 1.2 Confirmed via the pipeline's `list-updates` (zero history) and
      `last_modified` (today) that it had been silently recreated during an
      earlier `bundle deploy -t dev`, not merely lost data in place
- [x] 1.3 Confirmed via the user's own check that the Neon Postgres source
      data was fully intact — this is a Databricks-side ingestion-target gap,
      not source data loss
- [x] 1.4 Confirmed via Databricks' own docs that deleting a pipeline deletes
      its managed tables by default, explaining the original deletion's effect

## 2. Catalog-level grant

- [x] 2.1 Added `BROWSE` to `databricks_grants.cicd_catalog_use`'s privileges
      list — `terraform plan` showed 0 to add, 3 to change, 0 to destroy
- [x] 2.2 Applied — confirmed via re-triggering
      `neon_ecommerce_ingestion`'s CI/CD-SP-owned pipeline directly
      (`databricks pipelines start-update`): first attempt after this grant
      still failed, but on a *different* error (`CREATE TABLE and USE SCHEMA`
      — see below), proving `BROWSE` alone resolved the original error

## 3. Schema-level grant

- [x] 3.1 Added `local.cicd_writable_schemas` (all 6 bronze schemas) and
      `databricks_grants.cicd_schema_use` (`USE_SCHEMA`, `CREATE_TABLE`,
      `for_each` over environments × schemas) — `terraform plan` showed
      exactly 18 to add (6 schemas × 3 envs), 0 to change, 0 to destroy
- [x] 3.2 Applied — 18 added
- [x] 3.3 Re-triggered `neon_ecommerce_ingestion`'s CI/CD-SP-owned pipeline —
      `COMPLETED`. `databricks tables list mdp_dev bronze_neon` shows all four
      `*_raw` tables present as `STREAMING_TABLE`
- [x] 3.4 Verified row counts match the original seed exactly: 200 customers,
      50 products, 500 orders, 1240 order_items

## 4. Follow-up access

- [x] 4.1 Granted `handsonessential@gmail.com` `SELECT` on schema
      `mdp_dev.bronze_neon` (ad hoc SQL `GRANT`, not yet in Terraform — table
      ownership passed to the CI/CD SP once it created the table, so even
      workspace-admin membership didn't carry implicit `SELECT`) — flagged as
      a fast-follow to formalize in Terraform if human read access to
      SP-owned tables is needed on an ongoing basis, not done here to keep
      this change scoped to the SP's own execution grants

## 5. Documentation

- [x] 5.1 Added a "CI/CD service principal pipeline execution" section to
      this repo's CLAUDE.md covering the grants, the execution-identity
      finding, and the pipeline-deletion table-drop behavior
- [x] 5.2 Added a note to `demo-databricks-mdp`'s CLAUDE.md ("Operational
      notes") that the CI/CD SP's dev-prefixed pipeline/job copies are
      canonical going forward — the human-identity dev copies are disposable,
      safe to delete without data loss concern
