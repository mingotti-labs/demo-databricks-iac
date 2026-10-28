## Context

See proposal.md. `bronze_portfolio.s3_raw` (change `dividend-portfolio-schemas`)
is the template: a `databricks-uc-volume` module call per environment and one
`databricks_grants` resource giving `READ_VOLUME`/`WRITE_VOLUME` to the CI/CD
service principal and the human account. The schemas are one map in
`modules/databricks-unity-catalog/main.tf` plus `local.cicd_writable_schemas` in
each deployment. `free_workspace/main.tf` and `single_workspace/main.tf` are
identical today and stay so.

## Goals / Non-Goals

**Goals:**
- The three volumes exist before the mdp SEC change is implemented.
- Nothing unused from FMP or `reference` is left in Terraform or the workspace.

**Non-Goals:**
- Volumes for RBA or FRED (they decide their raw shape in their own changes).
- The `fred` scope (still needed for step 8).

## Decisions

- **D1 One volume module call per source**, as `portfolio_volume`
  (`sec_volume`, `yahoo_volume`, `wikipedia_volume`), each with its own grants
  resource. Rejected: a `for_each` over sources in one call. The existing two
  are separate calls; three more of the same is clearer than a new shape, and
  it keeps the existing volumes' addresses unchanged.
- **D2 Human account gets the grants too**, as `portfolio`: the user inspects
  files and may drop a file by hand while debugging. Rejected: SP only
  (clickstream's shape), which would block reading the files from the UI.
- **D3 Removal by deleting the code.** Terraform destroys the six schemas, their
  grants, the `fmp` scope, secret and ACL. A schema destroy fails if the schema
  is not empty (no `force_destroy` is set), which is the safety check: all six
  were never written to. Confirmed by listing their tables before the apply.
- **D4 `fmp_api_key` variable removed from both deployments and the module.** The
  HCP workspace variable then becomes undeclared; the user deletes it after the
  apply (a leftover undeclared workspace variable only warns).

## Risks / Trade-offs

- [A plan destroys more than expected] → read the full plan; the expected counts
  are in proposal.md; apply only after the walk-through and the user's go-ahead.
  Pass `uc_external_ids` on every local plan (CLAUDE.md "Running Terraform
  locally"), or the plan also strips the IAM trust condition.
- [A removed schema holds a table after all] → the destroy fails rather than
  dropping data; check with `databricks tables list` first.

## Migration Plan

1. `databricks tables list mdp_<env> <schema>` for the six schemas in dev and
   prd: all empty.
2. `terraform plan` with the usual variables: 12 to add, 27 to destroy, nothing
   else changed.
3. Walk through the plan with the user; apply on the go-ahead.
4. Check: `databricks volumes list` shows `s3_raw` in the three schemas in both
   catalogs; `databricks grants get volume` shows both principals;
   `databricks schemas list` shows no `fmp` or `reference` schema;
   `databricks secrets list-scopes` shows no `fmp`.
5. The user deletes `fmp_api_key` from the HCP Terraform workspace.
Rollback: revert the commit and apply; the schemas and scope come back empty
(the FMP key would need setting again).

## Results (2026-10-28)

- The six schemas held no tables in dev and prd before the plan.
- `terraform plan`: 12 to add, 0 to change, 27 to destroy, as expected; no
  update or replacement. Applied with the user's go-ahead.
- `s3_raw` is listed in `bronze_sec`, `bronze_yahoo` and `bronze_wikipedia` in
  both catalogs; the CI/CD service principal and the human account hold
  `READ_VOLUME` and `WRITE_VOLUME` on each.
- No `fmp` or `reference` schema remains; `databricks secrets list-scopes` shows
  `airroi`, `atlas-mongodb`, `fred` and `neon-postgres`.
- Left for the user: delete `fmp_api_key` from the HCP Terraform workspace
  (task 3.5).
