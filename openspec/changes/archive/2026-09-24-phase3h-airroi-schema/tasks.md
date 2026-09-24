## 1. Schema map

- [x] 1.1 Added `bronze_airroi` and `bronze_airroi_publish` to
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 `terraform plan` showed exactly 14 to add (6 schemas + 6 CI/CD
      grants + 2 secret resources, all changes made before the first
      plan), 0 to change, 0 to destroy

## 2. Secret scope

- [x] 2.1 Added `databricks_secret_scope.airroi` and
      `databricks_secret.airroi_api_key` (key `api_key`, value
      `var.airroi_api_key`) to `modules/databricks-secret-scopes/main.tf`,
      plus the `sensitive = true` variable in that module's `variables.tf`
      and the root `deployment/free_workspace/variables.tf` (threaded
      through, since AirROI's key is an external credential with no
      provisioning submodule, unlike Neon/Atlas)
- [x] 2.2 Confirmed `var.airroi_api_key` was already set in the HCP
      Terraform workspace — `terraform plan` showed a clean value
      assignment, no prompt for a missing variable

## 3. Apply and verify

- [x] 3.1 Applied — confirmed via direct queries against the real
      workspace (not just the apply log)
- [x] 3.2 `databricks schemas list mdp_dev`/`mdp_tst`/`mdp_prd` confirmed
      both new schemas present in all three catalogs
- [x] 3.3 `databricks secrets list-scopes` confirmed `airroi` exists;
      `databricks secrets list-secrets airroi` confirmed `api_key` is
      present (value not displayed, by design)

## 4. CI/CD SP grants (applied proactively, including CREATE_MATERIALIZED_VIEW)

- [x] 4.1 Added `bronze_airroi`/`bronze_airroi_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [x] 4.2 Covered by the same plan/apply as step 1.2/3.1; confirmed via
      `databricks grants get schema mdp_dev.bronze_airroi` that the CI/CD
      SP has `USE_SCHEMA`, `CREATE_TABLE`, and `CREATE_MATERIALIZED_VIEW`
      from the start

## 5. Documentation

- [x] 5.1 Added a note to this repo's CLAUDE.md ("Bronze schema shape"
      section and a new secret-scope note): the schemas and secret scope
      exist, consumed by an upcoming `demo-databricks-mdp` change; this is
      the first real (non-placeholder) third-party API secret in the
      project
