## ADDED Requirements

### Requirement: RBA landing volume
A managed Unity Catalog Volume named `s3_raw` SHALL exist per environment
catalog inside `bronze_rba`, backed by the catalog's existing bucket. It holds
the RBA's dated raw files written by its fetch task. The CI/CD service
principal and the human account SHALL hold `READ_VOLUME` and `WRITE_VOLUME` on
it.

#### Scenario: Volume created per environment
- **WHEN** `databricks volumes list <catalog> bronze_rba` is run for each
  environment catalog
- **THEN** `s3_raw` is listed

#### Scenario: Both principals can use the volume
- **WHEN** `databricks grants get volume <catalog>.bronze_rba.s3_raw` is run
- **THEN** the CI/CD service principal and the human account both hold
  `READ_VOLUME` and `WRITE_VOLUME`
