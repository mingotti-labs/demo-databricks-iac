## 1. Schema map

- [x] 1.1 Add `silver_landing_neon`, `silver_landing_clickstream`,
      `silver_landing_ungm`, `silver_landing_acnc`,
      `silver_landing_nsw_spatial`, and `silver_landing_airroi` to
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`, each
      with a descriptive comment matching the existing style
- [x] 1.2 `terraform plan` shows exactly 18 schema resources to add (6
      schemas × 3 environments) among the total — confirmed, see 3.1

## 2. CI/CD SP grants

- [x] 2.1 Add the same 6 schemas to `local.cicd_writable_schemas` in
      `deployment/free_workspace/main.tf`
- [x] 2.2 `terraform plan` shows 18 more `cicd_schema_use` grant resources
      to add (same 6 schemas × 3 environments), granting `USE_SCHEMA`,
      `CREATE_TABLE`, and `CREATE_MATERIALIZED_VIEW` from the start

## 3. Apply and verify

- [x] 3.1 Walked through the full plan output: **36 to add (18 schemas + 18
      grants), 0 to change, 0 to destroy**, across dev/tst/prd — nothing
      outside the 6 new schemas touched. Awaiting explicit go-ahead before
      applying
- [x] 3.2 Applied — `Apply complete! Resources: 36 added, 0 changed, 0
      destroyed.` Confirmed via direct queries against the real workspace
      (3.3/3.4), not just the apply log
- [x] 3.3 `databricks schemas list mdp_dev`/`mdp_tst`/`mdp_prd` confirmed
      all 6 new schemas present in all three catalogs
- [x] 3.4 `databricks grants get schema mdp_dev.silver_landing_neon` and
      `mdp_dev.silver_landing_airroi` confirmed the CI/CD SP
      (`74cc0004-a114-4e3d-aac2-d714aadb6910`) has `USE_SCHEMA`,
      `CREATE_TABLE`, and `CREATE_MATERIALIZED_VIEW` on both

## 4. Documentation

- [x] 4.1 Added a "Silver schema shape" section to this repo's CLAUDE.md:
      the 6 Silver Landing schemas exist, consumed by
      `demo-databricks-mdp`'s `phase4a-silver-landing` change
