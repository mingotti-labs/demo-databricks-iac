## 1. Module
- [x] 1.1 Create `modules/databricks-uc-pattern-schemas/` (`main.tf` with a `local.schemas` map of `pattern_bronze` and `pattern_bronze_publish` and a `databricks_schema` `for_each`, `variables.tf` with `catalog_name`, `outputs.tf` with the schema names)

## 2. Wire it in
- [x] 2.1 In `deployment/free_workspace/main.tf`, add `module "pattern_schemas"` with `catalog_name = module.unity_catalog["dev"].catalog_name`
- [x] 2.2 Mirror it in `deployment/single_workspace/main.tf`; `terraform init -backend=false` and `validate` there
- [x] 2.3 `terraform fmt` and `terraform validate` in `free_workspace`

## 3. Docs
- [x] 3.1 NAMING.md: `pattern_<layer>` schema rule (dev only); CLAUDE.md: a short "Pattern schemas" section

## 4. Plan and apply
- [x] 4.1 Local `terraform plan` (`environment=dev`, full `uc_external_ids` for `dev` and `prd`): expect 2 to add, 0 to change, 0 to destroy
- [x] 4.2 After the PR merges and with explicit approval, apply the reviewed plan
- [x] 4.3 Verify: `databricks schemas list mdp_dev` shows both schemas; `mdp_prd` shows none
