## MODIFIED Requirements

### Requirement: Bronze and gold schemas per catalog
Each catalog SHALL contain the schemas `bronze_neon`, `bronze_neon_publish`,
`bronze_atlas`, `bronze_atlas_publish`, `bronze_clickstream`,
`bronze_clickstream_publish`, `bronze_ungm`, `bronze_ungm_publish`,
`bronze_acnc`, `bronze_acnc_publish`, `gold_analytics_gateway`,
`gold_integration_gateway`, and `gold_ai_gateway`. Silver schemas SHALL NOT
be created in Phase 1, since domains are not yet defined. No
`bronze_<source>_history` schema SHALL exist — full change history/CDC
replay, where needed, is modeled as `<table>_scd2` inside the source's
`_publish` schema instead.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each of `mdp_dev`,
  `mdp_tst`, `mdp_prd`
- **THEN** all thirteen schemas listed above are present in each catalog, no
  silver schema is present, and no `bronze_<source>_history` schema is present
