## MODIFIED Requirements

### Requirement: Bronze and gold schemas per catalog
Each catalog SHALL contain the schemas `bronze_neon`, `bronze_neon_publish`,
`bronze_atlas`, `bronze_atlas_publish`, `bronze_clickstream`,
`bronze_clickstream_publish`, `bronze_ungm`, `bronze_ungm_publish`,
`bronze_acnc`, `bronze_acnc_publish`, `bronze_nsw_spatial`,
`bronze_nsw_spatial_publish`, `bronze_airroi`, `bronze_airroi_publish`,
`bronze_iso`, `bronze_iso_publish`, `bronze_geonames`,
`bronze_geonames_publish`, `silver_landing_neon`,
`silver_landing_clickstream`, `silver_landing_ungm`, `silver_landing_acnc`,
`silver_landing_nsw_spatial`, `silver_landing_airroi`, `silver_landing_iso`,
`silver_landing_geonames`, `silver_normalised_airroi`,
`silver_normalised_acnc`, `gold_analytics_gateway`,
`gold_integration_gateway`, and `gold_ai_gateway`; and, for the dividend
portfolio story, `bronze_<s>`, `bronze_<s>_publish` and `silver_landing_<s>`
for each `<s>` of `wikipedia`, `sec`, `yahoo`, `rba`, `fred` and `portfolio`,
plus the Silver Domain schema `silver_investments`. No `fmp` or `reference`
schema SHALL exist (FMP was dropped after its probe; reference data lives in
`portfolio`). A Silver Domain schema SHALL exist only once a story defines its
domain; `silver_investments` is the first. No `bronze_<source>_history` schema
SHALL exist — full change history/CDC replay, where needed, is modeled as
`<table>_scd2` inside the source's `_publish` schema instead.

The `free_workspace` deployment differs, to stay under Free Edition's
50-schemas-per-catalog quota: its catalogs SHALL NOT contain `bronze_atlas`,
`bronze_atlas_publish` or any `silver_landing_<source>` schema, and SHALL
contain one `silver_landing` schema for every source's Silver Landing tables,
each named `<source>__<entity>`. `single_workspace` keeps the list above.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each environment
  catalog of `single_workspace`
- **THEN** all fifty schemas listed above are present in each catalog, no
  `fmp` or `reference` schema is present, no Silver Domain schema other than
  `silver_investments` is present, and no `bronze_<source>_history` schema is
  present

#### Scenario: Free workspace has one Silver Landing schema for new sources
- **WHEN** `databricks schemas list mdp_dev` and `databricks schemas list
  mdp_prd` are run after apply
- **THEN** `silver_landing` is listed, and `bronze_atlas`,
  `bronze_atlas_publish` and every `silver_landing_<source>` schema are not

#### Scenario: Free workspace catalogs are under the schema quota
- **WHEN** `databricks resource-quotas get-quota catalog <catalog>
  schema-quota` is run for `mdp_dev` and `mdp_prd`
- **THEN** `quota_count` is below `quota_limit` (50) for both

#### Scenario: CI/CD principal can build tables in the story's schemas
- **WHEN** `databricks grants get schema <catalog>.silver_investments` (or any
  of the story's new schemas, or `silver_landing`) is run
- **THEN** the CI/CD service principal holds `USE_SCHEMA`, `CREATE_TABLE` and
  `CREATE_MATERIALIZED_VIEW`, and the human account holds `SELECT`

