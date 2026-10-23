## Context

`modules/databricks-secret-scopes` outputs `neon_scope_name`. The deployment
files (`deployment/free_workspace/main.tf`, `deployment/single_workspace/main.tf`)
hold the airroi ACL (`databricks_secret_acl.cicd_airroi_read`) with the comment
explaining why. The neon grant follows it.

## Decisions

- **D1 Same shape as airroi:** a `databricks_secret_acl` in each active
  deployment, principal `module.identity_governance.cicd_client_id`, permission
  `READ`, scope `module.secret_scopes.neon_scope_name`.
- **D2 Not in the module:** the module owns scopes and secrets; who may read them
  is deployment policy, as for airroi.
- **D3 Atlas left alone:** no code reads it at runtime.

## Risks

- `terraform apply` is blocked by the auto-mode classifier regardless of earlier
  go-ahead; apply while the user is present.
- Giving read access to database credentials widens what the service principal
  can do. The scope is the Neon `dev` branch, and the principal already uses
  those credentials indirectly through the UC Connection.
