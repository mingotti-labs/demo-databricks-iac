## ADDED Requirements

### Requirement: Source landing volumes for SEC, Yahoo and Wikipedia
A managed Unity Catalog Volume named `s3_raw` SHALL exist per environment
catalog inside each of `bronze_sec`, `bronze_yahoo` and `bronze_wikipedia`,
backed by the catalog's existing bucket. Each holds that source's dated raw
files written by its fetch task. The CI/CD service principal and the human
account SHALL hold `READ_VOLUME` and `WRITE_VOLUME` on each.

#### Scenario: Volumes created per environment
- **WHEN** `databricks volumes list <catalog> bronze_sec` (and `bronze_yahoo`,
  `bronze_wikipedia`) is run for each environment catalog
- **THEN** `s3_raw` is listed

#### Scenario: Both principals can use the volumes
- **WHEN** `databricks grants get volume <catalog>.bronze_sec.s3_raw` (and the
  other two) is run
- **THEN** the CI/CD service principal and the human account both hold
  `READ_VOLUME` and `WRITE_VOLUME`
