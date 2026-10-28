## 1. Volumes

- [x] 1.1 Add `sec_volume`, `yahoo_volume`, `wikipedia_volume` module calls
      (`s3_raw` in each `bronze_<source>`, per environment) and their
      `databricks_grants` (CI/CD service principal and human account,
      `READ_VOLUME`/`WRITE_VOLUME`) in both deployments; the two `main.tf`
      files stay identical (`diff` shows nothing)

## 2. Removals

- [x] 2.1 Remove the six `fmp` and `reference` schemas from `local.schemas` in
      `modules/databricks-unity-catalog/main.tf` and from
      `local.cicd_writable_schemas` in both deployments
- [x] 2.2 Remove the `fmp` scope and secret, the `fmp_api_key` variable and the
      scope-name output from `modules/databricks-secret-scopes/`, and the
      `fmp_api_key` variable, module argument and `cicd_fmp_read` ACL from both
      deployments; `grep -rn fmp modules deployment` returns nothing
- [x] 2.3 `terraform fmt -check -recursive` and `terraform validate` pass

## 3. Plan and apply

- [x] 3.1 The six schemas are empty in dev and prd (`databricks tables list`)
- [x] 3.2 `terraform plan`: 12 to add, 27 to destroy, nothing else; walk through
      it with the user
- [x] 3.3 Apply with the user's go-ahead
- [x] 3.4 Run the checks in design.md's Migration Plan step 4
- [ ] 3.5 The user deletes `fmp_api_key` from the HCP Terraform workspace

## 4. Documentation

- [x] 4.1 CLAUDE.md: the three volumes under "UC Volumes"; the `fmp` scope and
      the `fmp`/`reference` schemas marked removed (with why) in "Secret scopes"
      and "Silver schema shape"
