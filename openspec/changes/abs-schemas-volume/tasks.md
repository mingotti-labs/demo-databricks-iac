## 1. Schemas

- [x] 1.1 `bronze_abs`, `bronze_abs_publish` in `local.schemas` and
      `local.cicd_writable_schemas` of `deployment/free_workspace/main.tf`
- [x] 1.2 `bronze_abs`, `bronze_abs_publish`, `silver_landing_abs` in the module
      default map (`modules/databricks-unity-catalog/variables.tf`) and in
      `cicd_writable_schemas` of `deployment/single_workspace/main.tf`

## 2. Volume

- [x] 2.1 `module "abs_volume"` and `databricks_grants.abs_volume_use` in
      `deployment/free_workspace/main.tf` (copy of the FRED block)
- [x] 2.2 Same in `deployment/single_workspace/main.tf`

## 3. Plan and apply

- [x] 3.1 `terraform plan` on `free_workspace`: 12 to add, nothing else
- [ ] 3.2 Apply with the user's go-ahead
- [ ] 3.3 Run the checks in design.md's Migration Plan

## 4. Documentation

- [x] 4.1 CLAUDE.md: `abs` in the dividend story's schema list and the ABS volume
      next to the FRED one
