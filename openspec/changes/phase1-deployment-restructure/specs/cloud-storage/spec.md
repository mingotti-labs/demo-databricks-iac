## MODIFIED Requirements

### Requirement: S3 bucket
Three S3 buckets SHALL exist, one per environment catalog — `hoe-mdp-dev`, `hoe-mdp-tst`, `hoe-mdp-prd` — each in `ap-southeast-2` with versioning enabled and all public access blocked.

#### Scenario: Bucket provisioned
- **WHEN** the cloud-storage module is applied once per environment
- **THEN** three S3 buckets (`hoe-mdp-dev`, `hoe-mdp-tst`, `hoe-mdp-prd`) exist in `ap-southeast-2`, each with versioning enabled and all public-access-block settings enabled

### Requirement: IAM role for Unity Catalog
An IAM role SHALL exist per bucket, scoped to that bucket only, that Databricks Unity Catalog can assume to access it.

#### Scenario: Role assumable by Unity Catalog
- **WHEN** Unity Catalog uses the storage credential backed by one of these roles
- **THEN** it can assume that IAM role to read and write objects in its own bucket, and that role cannot access either of the other two buckets

### Requirement: Scoped IAM policy
Each IAM role SHALL have an attached policy granting only `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, and `s3:ListBucket`, scoped to its own bucket only.

#### Scenario: Policy grants only the required actions
- **WHEN** the IAM policy attached to one of the three roles is evaluated
- **THEN** it grants `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, and `s3:ListBucket` on that role's own bucket and its objects only, and no other resources — including the other two buckets
