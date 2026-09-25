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
`silver_landing_nsw_spatial`, `silver_landing_airroi`,
`gold_analytics_gateway`, `gold_integration_gateway`, and `gold_ai_gateway`.
Silver Domain/Marts schemas SHALL NOT be created yet, since domains are not
yet defined — only source-aligned Silver Landing schemas exist so far. No
`bronze_<source>_history` schema SHALL exist — full change history/CDC
replay, where needed, is modeled as `<table>_scd2` inside the source's
`_publish` schema instead.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each of `mdp_dev`,
  `mdp_tst`, `mdp_prd`
- **THEN** all twenty-seven schemas listed above are present in each
  catalog, no Silver Domain/Marts schema is present, and no
  `bronze_<source>_history` schema is present
