# uc-volumes Specification

## Purpose
Provisions Unity Catalog Volume objects that give file-drop ingestion sources
(Auto Loader) a governed landing path, scoped one volume per source system so
access grants stay isolated per source rather than shared across sources.

## Requirements

### Requirement: Clickstream landing volume
A managed Unity Catalog Volume named `s3_clickstream_raw` SHALL exist per
environment catalog, inside that catalog's `bronze_clickstream` schema, backed by
the same S3 bucket already used as that catalog's storage root — no separate
bucket, storage credential, or external location.

#### Scenario: Volume created per environment
- **WHEN** the databricks-uc-volume module is applied once per environment
- **THEN** three volumes exist, each named `s3_clickstream_raw`, at
  `mdp_dev.bronze_clickstream.s3_clickstream_raw`,
  `mdp_tst.bronze_clickstream.s3_clickstream_raw`, and
  `mdp_prd.bronze_clickstream.s3_clickstream_raw`

### Requirement: One volume per source system
UC Volumes provisioned by this capability SHALL NOT be shared across source
systems — each source system gets its own dedicated volume inside its own
`bronze_<source>` schema, so `READ VOLUME`/`WRITE VOLUME` grants can be scoped to
one source at a time.

#### Scenario: Volume access is scoped to one source
- **WHEN** a principal is granted `WRITE VOLUME` on `s3_clickstream_raw`
- **THEN** that grant provides no access to any other source system's data, since
  no other source system's files live in this volume
