## Context

`silver_investments` is listed in three places: the module's default schema
map (`modules/databricks-unity-catalog/variables.tf`), `free_workspace`'s
`local.schemas` and `cicd_writable_schemas`, and `single_workspace`'s
`cicd_writable_schemas`. The schema is empty in `mdp_dev` and `mdp_prd`.

## Decisions

- **Replace, not rename in place.** A schema's name is its identity in Unity
  Catalog and in Terraform's map key, so Terraform destroys the old schema and
  creates the new one. That is safe only because the old one is empty, which
  the first task checks before the plan. Alternative: `ALTER SCHEMA ... RENAME`
  outside Terraform, then a state move. Rejected: more steps for an empty
  schema.
- **Same grants**: the new name goes where the old one was in every list, so
  the CI/CD and human grants follow without new code.

## Risks / Trade-offs

- [A table was created in `silver_investments` since it was checked] → the
  first task lists its tables right before the plan; the destroy fails on a
  non-empty schema rather than dropping data, unless `force_destroy` is set,
  which the plan review checks.

## Migration Plan

1. Check `silver_investments` is empty in both catalogs.
2. Edit the three lists and the docs; `terraform plan` on `free_workspace`
   shown in full; apply after the user's go-ahead.
3. Verify with `databricks schemas list` and `databricks grants get schema`.

Rollback: revert the edit and apply; the old empty schema comes back.
