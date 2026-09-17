# cloud-storage Specification

## Purpose

Provides S3 object storage and an IAM role that Unity Catalog assumes to read and write Delta tables for the platform.

## Requirements

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

### Requirement: IAM trust policy scoped to Databricks
The IAM role's trust policy SHALL restrict assumption to the Databricks account principal, and once the storage credential's `external_id` is known, SHALL also require that `external_id` in the trust condition.

#### Scenario: First apply, no external_id yet
- **WHEN** the IAM role is first created
- **THEN** the trust policy allows assumption only by the Databricks account principal, with no `external_id` condition

#### Scenario: Second apply hardens the trust policy
- **WHEN** the storage credential's `external_id` is retrieved and added to the role's trust policy
- **THEN** re-applying shows only the IAM role resource with an in-place update, and the trust policy now requires that `external_id`

### Requirement: Scoped IAM policy
Each IAM role SHALL have an attached policy granting only `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, and `s3:ListBucket`, scoped to its own bucket only.

#### Scenario: Policy grants only the required actions
- **WHEN** the IAM policy attached to one of the three roles is evaluated
- **THEN** it grants `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, and `s3:ListBucket` on that role's own bucket and its objects only, and no other resources — including the other two buckets

### Requirement: Module outputs for downstream wiring
The cloud-storage module SHALL expose `bucket_name`, `bucket_arn`, and `iam_role_arn` as outputs.

#### Scenario: Outputs available to the unity-catalog module
- **WHEN** `terraform plan` runs with the cloud-storage module called from root
- **THEN** `bucket_name`, `bucket_arn`, and `iam_role_arn` appear in the plan output
