## Context

See proposal.md. Free Edition caps each catalog at 50 schemas. Counts on
2026-10-30 (`databricks resource-quotas get-quota catalog <c> schema-quota`):
`mdp_dev` 52 (the 50 managed schemas plus `pattern_bronze` and
`pattern_bronze_publish`), `mdp_prd` 50. Tables in the four schemas to drop,
checked with `databricks tables list` the same day: 0 in each, in both
catalogs.

## Goals / Non-Goals

**Goals:**
- Room under the quota in both free catalogs, and the `silver_landing` schema
  the mdp change needs.
- `single_workspace` unchanged (user's decision).

**Non-Goals:**
- Dropping the twelve `silver_landing_<source>` schemas that hold tables: they
  go in a later iac change, once mdp has moved its tables.
- Folding `bronze_<source>_publish` or `silver_normalised_<source>` schemas.

## Decisions

**The schema map becomes a module variable with today's map as default.**
`modules/databricks-unity-catalog` builds every schema from `local.schemas`,
shared by both deployments. Making it `var.schemas` with the current map as
its default leaves `single_workspace` untouched (it passes nothing), while
`free_workspace` passes its own map. The free map sits in
`deployment/free_workspace/main.tf` next to `local.cicd_writable_schemas`, so
the two lists that must agree are in one file. Resource addresses stay
`module.unity_catalog["<env>"].databricks_schema.this["<schema>"]`, so the
plan only touches the schemas that really change.

Rejected: a flag such as `single_silver_landing = true` that edits the list
inside the module. It hides which schemas the free workspace has behind
logic; a plain map is easier to read and to diff.

**Drop exactly four schemas now.** dev needs three freed slots to create one
(52 -> 49 -> 50 would leave no spare), prd needs one. The four chosen are
empty in both catalogs and have no consumer:
- `silver_landing_rba`, `silver_landing_fred`: RBA and FRED Landing tables will
  be created directly as `silver_landing.rba__*` and `silver_landing.fred__*`.
- `bronze_atlas`, `bronze_atlas_publish`: created in Phase 1 for MongoDB Atlas,
  never used by mdp. The Atlas project, `modules/atlas/` and the
  `atlas-mongodb` scope stay; a schema can be recreated when a change ingests
  Atlas.

`pattern_bronze` and `pattern_bronze_publish` stay: the patterns bundle uses
them.

**`silver_landing` gets the same grants as every Landing schema**, through
`local.cicd_writable_schemas`. Comment: "Source-aligned Silver Landing for
every source; tables are named `<source>__<entity>`".

## Risks / Trade-offs

- [`free_workspace` and `single_workspace` schema lists differ] -> Accepted by
  the user; mdp's standard edition (`cicd/databricks/standard.yml`) will stop
  matching `single_workspace`, which is an unapplied reference copy.
- [A dropped schema has a table by apply time] -> `databricks_schema` does not
  force-destroy, so the apply fails on that schema instead of losing data;
  re-check the counts just before apply.

## Migration Plan

1. Re-check the four schemas hold no tables in `mdp_dev` and `mdp_prd`.
2. `terraform plan` on `free_workspace`: 4 to add, 0 to change, 16 to
   destroy, nothing else.
3. Apply with the user's go-ahead.
4. Check: `databricks schemas list mdp_dev|mdp_prd` shows `silver_landing`
   and none of the four; `databricks grants get schema
   mdp_dev.silver_landing` shows the CI/CD and human grants; schema quota
   reads 49 (dev) and 47 (prd).

Rollback: put the four entries back in the free map and apply; the schemas
come back empty, as they were.
