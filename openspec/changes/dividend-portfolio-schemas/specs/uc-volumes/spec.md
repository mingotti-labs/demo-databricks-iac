## ADDED Requirements

### Requirement: Portfolio landing volume
A managed Unity Catalog Volume named `s3_portfolio_raw` SHALL exist per
environment catalog, inside that catalog's `bronze_portfolio` schema, backed by
the catalog's existing bucket. It holds the user's purchases CSV. The CI/CD
service principal SHALL hold `READ_VOLUME` and `WRITE_VOLUME` on it, and so
SHALL the human account, who uploads the file.

#### Scenario: Volume created per environment
- **WHEN** `databricks volumes list <catalog> bronze_portfolio` is run for each
  environment catalog
- **THEN** `s3_portfolio_raw` is listed

#### Scenario: Both principals can use the volume
- **WHEN** `databricks grants get volume <catalog>.bronze_portfolio.s3_portfolio_raw`
  is run
- **THEN** the CI/CD service principal and the human account both hold
  `READ_VOLUME` and `WRITE_VOLUME`
