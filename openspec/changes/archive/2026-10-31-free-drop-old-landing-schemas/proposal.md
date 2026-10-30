## Why

`free-silver-landing-schema` created one `silver_landing` schema in the free
workspace, and `demo-databricks-mdp`'s `single-silver-landing-schema` (archived
2026-10-31) moved every Silver Landing table into it as `<source>__<entity>`
and dropped the old tables, with the user's approval. The twelve
`silver_landing_<source>` schemas are now empty in both catalogs and only use
schema quota (`mdp_dev` 49/50, `mdp_prd` 47/50 on 2026-10-31). This is the
last of the three steps.

## What Changes

- **Drop the twelve `silver_landing_<source>` schemas** from the free
  workspace's map (`local.schemas`) and from `local.cicd_writable_schemas`:
  `neon`, `clickstream`, `ungm`, `acnc`, `nsw_spatial`, `airroi`, `iso`,
  `geonames`, `wikipedia`, `sec`, `yahoo`, `portfolio`. Checked 2026-10-31: no
  tables, volumes or functions in any of them, in `mdp_dev` and `mdp_prd`.
- Docs: CLAUDE.md stops saying the old schemas remain.
- Not included: `single_workspace` (keeps one Landing schema per source, the
  user's decision), any other schema.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the free workspace has no `silver_landing_<source>`
  schemas.

## Cross-repo dependencies

Depends on `single-silver-landing-schema` in `demo-databricks-mdp` (done,
archived): its tables now live in `silver_landing`, so nothing reads or writes
the old schemas. mdp's `cicd/databricks/standard.yml` still names
`silver_landing_neon`; that is the standard edition, which follows
`single_workspace` and is allowed to drift (user's decision).

## Model

Sonnet to implement: removing entries from two lists.

## Impact

- `terraform plan` on `free_workspace` should show **0 to add, 0 to change,
  48 to destroy**: twelve schemas and their twelve grants, per catalog.
- Schema quota afterwards: `mdp_dev` 37, `mdp_prd` 35. No tables, so the
  500-table quota is untouched.
- Apply needs the user's explicit go-ahead.
