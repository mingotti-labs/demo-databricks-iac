## 1. Repo scaffolding

- [ ] 1.1 Create `modules/aws-s3/`, `modules/databricks-unity-catalog/`, `modules/neon/`, `modules/atlas/`, `modules/databricks-secret-scopes/` directories each with `main.tf`, `variables.tf`, `outputs.tf` stubs — verify all 15 files exist
- [ ] 1.2 Create `envs/dev/main.tf`, `envs/dev/variables.tf`, `envs/dev/dev.tfvars.example` — verify files exist and `dev.tfvars` is listed in `.gitignore`

## 2. aws-s3 module

- [ ] 2.1 Implement `modules/aws-s3/`: S3 bucket (versioning on, public access blocked), IAM role with trust policy supporting optional `uc_external_id` condition, scoped IAM policy — verify `terraform validate` passes
- [ ] 2.2 Add outputs `bucket_name`, `bucket_arn`, `iam_role_arn` — verify they appear in `terraform plan` output when module is called from root

## 3. neon module

- [ ] 3.1 Implement `modules/neon/`: Neon project + database + role using `neon-database/neon` provider — verify `terraform validate` passes
- [ ] 3.2 Add outputs `host`, `database_name`, `role_name`, `password` — verify plan shows resource creation

## 4. atlas module

- [ ] 4.1 Implement `modules/atlas/`: Atlas project + M0 cluster + database user using `mongodb/mongodbatlas` provider — verify `terraform validate` passes
- [ ] 4.2 Add outputs `connection_string`, `username`, `password` — verify plan shows resource creation

## 5. databricks-unity-catalog module

- [ ] 5.1 Implement storage credential and external location using `iam_role_arn` and `bucket_name` inputs — verify `terraform validate` passes
- [ ] 5.2 Implement catalogs `mdp_dev`, `mdp_tst`, `mdp_prd` with all 9 schemas each — verify schema list matches spec

## 6. databricks-secret-scopes module

- [ ] 6.1 Implement secret scope `neon-postgres` with keys `host`, `database_name`, `role_name`, `password` — verify `terraform validate` passes
- [ ] 6.2 Implement secret scope `atlas-mongodb` with keys `connection_string`, `username`, `password` — verify `terraform validate` passes

## 7. Root module wiring

- [ ] 7.1 Wire all five modules in `envs/dev/main.tf`: aws-s3 outputs → unity-catalog inputs; neon + atlas outputs → secret-scopes inputs — verify `terraform validate` passes in `envs/dev/`
- [ ] 7.2 Add all required variables to `envs/dev/variables.tf` and update `dev.tfvars.example` with placeholders — verify `terraform plan -var-file=dev.tfvars` runs without variable errors

## 8. First apply (pass 1)

- [ ] 8.1 Copy `dev.tfvars.example` to `dev.tfvars`, fill in non-sensitive values; confirm sensitive variables are set in HCP Terraform workspace — verify `terraform plan -var-file=dev.tfvars` shows expected resources with no errors
- [ ] 8.2 Run `terraform apply -var-file=dev.tfvars` — verify apply completes cleanly and HCP workspace shows state

## 9. Harden IAM trust policy (pass 2)

- [ ] 9.1 Retrieve `uc_external_id` from `terraform output` and add it to `dev.tfvars` — verify the value is non-empty
- [ ] 9.2 Run `terraform apply -var-file=dev.tfvars` — verify apply completes with only the IAM role showing an in-place update, all other resources unchanged

## 10. Verification

- [ ] 10.1 Confirm Unity Catalog shows `mdp_dev`, `mdp_tst`, `mdp_prd` catalogs with all 9 schemas each in the Databricks workspace UI
- [ ] 10.2 Confirm external location is visible under Unity Catalog > External Locations in the Databricks workspace UI
- [ ] 10.3 Run `databricks secrets list-scopes` and confirm `neon-postgres` and `atlas-mongodb` are listed
