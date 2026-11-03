## ADDED Requirements

### Requirement: ABS landing volume
A managed Unity Catalog Volume named `s3_raw` SHALL exist per environment
catalog inside `bronze_abs`, backed by the catalog's existing bucket. It holds
the Australian Bureau of Statistics' dated raw CPI files written by its fetch
task. The CI/CD service principal and the human account SHALL hold
`READ_VOLUME` and `WRITE_VOLUME` on it.

#### Scenario: Volume created per environment
- **WHEN** `databricks volumes list <catalog> bronze_abs` is run for each
  environment catalog
- **THEN** `s3_raw` is listed

#### Scenario: Both principals can use the volume
- **WHEN** `databricks grants get volume <catalog>.bronze_abs.s3_raw` is run
- **THEN** the CI/CD service principal and the human account both hold
  `READ_VOLUME` and `WRITE_VOLUME`
