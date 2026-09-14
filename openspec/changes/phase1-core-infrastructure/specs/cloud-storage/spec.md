## ADDED Requirements

- An S3 bucket named `hoe-mdp-dev` exists in `ap-southeast-2` with versioning enabled and all public access blocked
- An IAM role exists that Databricks Unity Catalog can assume to access the bucket
- The IAM role's trust policy restricts assumption to the Databricks account principal; on second apply it also requires the storage credential's `external_id`
- An IAM policy attached to the role grants `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, and `s3:ListBucket` scoped to the bucket only
- The bucket ARN and IAM role ARN are available as Terraform outputs for use by the unity-catalog module
