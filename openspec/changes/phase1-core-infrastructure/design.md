## Context

Fresh repo with only `terraform.tf` (HCP Terraform backend configured) and `envs/dev/` skeleton. No modules exist yet. Target: Databricks Free Edition (AWS, single workspace `https://dbc-e3197e2d-933b.cloud.databricks.com`, single metastore). See proposal.md for motivation.

## Goals / Non-Goals

**Goals:** Apply all five modules in a single `terraform apply` from `envs/dev/`. All resources fully managed by Terraform state in HCP.

**Non-Goals:** `tst/` and `prd/` env apply (Phase 2+). Silver schemas (domains undefined). Account-level Terraform resources (Free Edition has no account API).

## Decisions

**Flat modules, orchestrated by root**
Five modules (`aws-s3`, `databricks-unity-catalog`, `neon`, `atlas`, `databricks-secret-scopes`) live under `modules/`. `envs/dev/main.tf` is the root that calls all modules and wires cross-module outputs to inputs. No module-to-module references — the root is the single wiring point. Alternative (nested modules) adds indirection with no benefit at this scale.

**Two-pass apply for Unity Catalog storage credential**
The IAM trust policy for the storage credential requires an `external_id` that Unity Catalog generates — which only exists after the storage credential is first created (circular dependency). Resolution: `uc_external_id` variable defaults to `""` (trust policy condition omitted on first apply). After first apply, output the `external_id`, add it to `dev.tfvars`, re-apply to harden the policy. This is a one-time setup step.

**Neon over AWS RDS**
AWS free tier was not available for this project. Neon free-tier serverless Postgres has no ongoing cost, supports logical replication (needed for Phase 3 CDC), and has a first-class Terraform provider. RDS would incur cost from day one.

**Sensitive variables in HCP Terraform, non-sensitive in dev.tfvars**
Secrets (AWS keys, Databricks token, Neon API key, Atlas keys) live exclusively in HCP Terraform variable sets — never written to disk or git. Non-sensitive config (region, bucket name, host, org ID) lives in `dev.tfvars` (gitignored). `dev.tfvars.example` is committed as a template with placeholders.

**mongodb/mongodbatlas provider (not hashicorp/mongodbatlas)**
The canonical registry namespace is `mongodb/mongodbatlas`. The `hashicorp/` namespace does not host this provider.

## Risks / Trade-offs

- **Two-pass apply friction** → Mitigated by documenting the exact steps in the implementation plan; only happens once per environment.
- **Neon provider maturity** → Neon's Terraform provider is community-maintained and may lag the API. Verify namespace at `registry.terraform.io/providers/neon-database/neon` at implementation time.
- **M0 Atlas cluster limitations** → M0 is free but has no SLA and limited throughput. Acceptable for demo purposes; not for production.
- **IAM role ARN in state** → Role ARN is non-sensitive but stored in HCP Terraform state. HCP state is encrypted at rest; acceptable.

## Migration Plan

1. First apply: creates S3 + IAM role, Neon, Atlas, Unity Catalog storage credential + external location + catalogs/schemas, secret scopes. IAM trust policy has no `external_id` condition.
2. Retrieve `uc_external_id` from Terraform output.
3. Add `uc_external_id` to `dev.tfvars`.
4. Second apply: hardens IAM trust policy with `external_id` condition. All other resources show no changes.

Rollback: `terraform destroy` removes all managed resources. No data migration needed (no data exists yet).

## Open Questions

- Exact Neon provider version to pin — verify at implementation time.
