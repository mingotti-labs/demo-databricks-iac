## MODIFIED Requirements

### Requirement: Bronze and gold schemas per catalog
Each catalog SHALL contain the schemas `bronze_neon`, `bronze_neon_history`,
`bronze_neon_publish`, `bronze_atlas`, `bronze_atlas_history`,
`bronze_atlas_publish`, `bronze_clickstream`, `gold_analytics_gateway`,
`gold_integration_gateway`, and `gold_ai_gateway`. Silver schemas SHALL NOT be
created in Phase 1, since domains are not yet defined.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each of `mdp_dev`,
  `mdp_tst`, `mdp_prd`
- **THEN** all ten schemas listed above are present in each catalog, and no
  silver schema is present
