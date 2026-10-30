## 1. Schema map per deployment

- [ ] 1.1 In `modules/databricks-unity-catalog`, move `local.schemas` to a
      variable `schemas` (map of name to comment) whose default is today's
      map; `databricks_schema.this` iterates `var.schemas`
- [ ] 1.2 `terraform plan` on `free_workspace` with no other edit: no changes

## 2. Free workspace schemas

- [ ] 2.1 In `deployment/free_workspace/main.tf`, add `local.schemas` (today's
      map without `silver_landing_rba`, `silver_landing_fred`, `bronze_atlas`,
      `bronze_atlas_publish`, plus `silver_landing`) and pass it to
      `module.unity_catalog`
- [ ] 2.2 Same edit to `local.cicd_writable_schemas` in that file; its comment
      points at `local.schemas` in the same file
- [ ] 2.3 `single_workspace` untouched (`git diff --stat` shows no file there)

## 3. Plan and apply

- [ ] 3.1 Re-check the four schemas hold no tables in `mdp_dev` and `mdp_prd`
- [ ] 3.2 `terraform plan`: 4 to add, 0 to change, 16 to destroy, nothing else
- [ ] 3.3 Apply with the user's go-ahead
- [ ] 3.4 Run the checks in design.md's Migration Plan

## 4. Documentation

- [ ] 4.1 CLAUDE.md "Silver schema shape": the free workspace has one
      `silver_landing` schema (tables `<source>__<entity>`), the per-source
      Landing schemas go once mdp has moved; `single_workspace` keeps one per
      source; note the 50-schemas-per-catalog quota
- [ ] 4.2 CLAUDE.md "Bronze schema shape": the Atlas schemas were removed from
      the free workspace (empty, unused)
- [ ] 4.3 NAMING.md: add a "Schemas" section with the `silver_landing` rule
      (`<source>__<entity>` table names, free workspace)
