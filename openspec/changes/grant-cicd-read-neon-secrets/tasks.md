## 1. Terraform
- [ ] 1.1 Add `databricks_secret_acl.cicd_neon_read` (READ for the CI/CD principal on the neon scope) next to the airroi one in `free_workspace` and `single_workspace`
- [ ] 1.2 `terraform plan` reviewed in full: one added resource, nothing else
- [ ] 1.3 Apply with the user's explicit go-ahead (user present)

## 2. Verify
- [ ] 2.1 `databricks secrets list-acls neon-postgres` lists the service principal with READ
- [ ] 2.2 In `demo-databricks-mdp`, the neon seed-data and source-versus-bronze checks run as the service principal (see its `refactor-airroi-clickstream-neon` change)

## 3. Docs
- [ ] 3.1 `secret-scopes` spec updated at archive; CLAUDE.md "CI/CD service principal pipeline execution" notes the neon grant
