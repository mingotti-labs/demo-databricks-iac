## 1. Schemas

- [ ] 1.1 Add the 25 schemas to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf`, with comments
- [ ] 1.2 Add the same 25 to `local.cicd_writable_schemas` in
      `deployment/free_workspace/main.tf` and
      `deployment/single_workspace/main.tf` (identical lists)

## 2. Secret scopes

- [ ] 2.1 Add `fmp` and `fred` scopes and their `api_key` secrets to
      `modules/databricks-secret-scopes/main.tf`, variables and scope-name
      outputs
- [ ] 2.2 Add sensitive root variables `fmp_api_key` and `fred_api_key` to both
      deployments and pass them to the module
- [ ] 2.3 Add `databricks_secret_acl` `READ` for the CI/CD service principal on
      both scopes, in both deployments

## 3. Volume

- [ ] 3.1 Add a `portfolio_volume` module call (`s3_raw` in
      `bronze_portfolio`, per environment) and a `databricks_grants` giving
      `READ_VOLUME`/`WRITE_VOLUME` to the CI/CD service principal and the human
      account, in both deployments

## 4. Plan and apply

- [ ] 4.1 User sets `fmp_api_key` and `fred_api_key` in HCP Terraform
- [ ] 4.2 `terraform plan`: additions only, counts match proposal.md
- [ ] 4.3 Apply with the user's go-ahead
- [ ] 4.4 Run the checks in design.md's Migration Plan

## 5. Documentation

- [ ] 5.1 CLAUDE.md: note the new schemas, scopes and volume and the story they
      serve
- [ ] 5.2 NAMING.md "UC Volumes": rule becomes `<service>_raw` (the schema
      already names the source); `s3_clickstream_raw` listed as the one
      exception, kept to avoid recreating the volume
