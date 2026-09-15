## Context

Fresh repo with only `terraform.tf` (HCP Terraform backend configured) and `envs/dev/` skeleton. No modules exist yet. Target: Databricks Free Edition (AWS, single workspace `https://dbc-e3197e2d-933b.cloud.databricks.com`, single metastore). See proposal.md for motivation.

## Goals / Non-Goals

**Goals:** Apply all five modules in a single `terraform apply` from `envs/dev/`. All resources fully managed by Terraform state in HCP.

**Non-Goals:** `tst/` and `prd/` env apply (Phase 2+). Silver schemas (domains undefined). Account-level Terraform resources (Free Edition has no account API).

## Decisions

**Flat modules, orchestrated by root**
Five modules (`aws-s3`, `databricks-unity-catalog`, `neon`, `atlas`, `databricks-secret-scopes`) live under `envs/dev/modules/`. `envs/dev/` is the actual Terraform root (backend, providers, `main.tf` wiring all modules, `variables.tf`, `dev.tfvars`) — not just a folder of tfvars. No module-to-module references — the root is the single wiring point.

**Terraform root lives in `envs/dev/`, not repo root; modules are nested under it**
Corrected during implementation (2026-09-15): the repo previously had a top-level `terraform.tf` (HCP Terraform backend) while `envs/dev/` held only tfvars. That split doesn't work — `envs/dev/main.tf` calling all modules requires `envs/dev/` to itself be the Terraform root, so the backend config moved there too. Modules are nested at `envs/dev/modules/` rather than a repo-root `modules/` sibling: HCP Terraform's CLI-driven remote execution only uploads the directory you run `terraform` from, and a local module `source` escaping that directory via `../` hits a confirmed Terraform bug on Windows (upstream GitHub #22824, #36545 — "Unreadable module directory" / symlink errors). Nesting modules under `envs/dev/` avoids the escape entirely (`source = "./modules/x"`).
**Follow-up needed in Phase 2:** when `envs/tst`/`envs/prd` are built as separate HCP Terraform workspaces, they cannot reuse `envs/dev/modules/` via a relative path for the same reason. Re-source the modules via a git URL (`source = "git::https://.../modules/aws-s3?ref=main"`, fetched server-side by HCP Terraform, immune to the local-upload limitation) rather than copy-pasting the module directories per environment.

**Two-pass apply for Unity Catalog storage credential**
The IAM trust policy for the storage credential requires an `external_id` that Unity Catalog generates — which only exists after the storage credential is first created (circular dependency). Resolution: `uc_external_id` variable defaults to `""` (trust policy condition omitted on first apply). After first apply, output the `external_id`, add it to `dev.tfvars`, re-apply to harden the policy. This is a one-time setup step.

**Neon over AWS RDS**
AWS free tier was not available for this project. Neon free-tier serverless Postgres has no ongoing cost, supports logical replication (needed for Phase 3 CDC), and has a first-class Terraform provider. RDS would incur cost from day one.

**Sensitive variables in HCP Terraform, non-sensitive in dev.tfvars**
Secrets (AWS keys, Databricks token, Neon API key, Atlas keys) live exclusively in HCP Terraform variable sets — never written to disk or git. Non-sensitive config (region, bucket name, host, org ID) lives in `dev.tfvars` (gitignored). `dev.tfvars.example` is committed as a template with placeholders.

**mongodb/mongodbatlas provider (not hashicorp/mongodbatlas)**
The canonical registry namespace is `mongodb/mongodbatlas`. The `hashicorp/` namespace does not host this provider. Cluster is created via `mongodbatlas_advanced_cluster` (provider v2.17.0) with `provider_name = "TENANT"`, `instance_size = "M0"` — the plain `mongodbatlas_cluster` resource is deprecated in favor of `advanced_cluster`.

**Neon provider is `kislerdm/neon`, not `neon-database/neon`**
Verified at implementation time (2026-09-15): `neon-database/neon` does not exist on the registry. The community-maintained provider is `kislerdm/neon` (v0.18.0). `neon_project` alone provisions project + default branch + database + role (via its optional `branch` block for custom names) — no separate `neon_database`/`neon_role` resources are needed to satisfy the spec.

**Additional fixes found during first apply (2026-09-15)**
- IAM role assumption for Unity Catalog requires the role to be able to assume *itself*, which needs two pieces AWS doesn't bundle automatically: (1) a trust-policy statement trusting the account root, scoped down via an `ArnLike` condition on `aws:PrincipalArn` to the role's own ARN (not a direct self-referencing principal, which IAM disallows) — matches the official `databricks_aws_unity_catalog_assume_role_policy` data source and the `databricks/terraform-databricks-examples` reference module; (2) a matching identity-based policy statement granting the role `sts:AssumeRole` on itself. Missing either half produces "IAM role ... was found to be non self-assuming".
- IAM changes need a propagation wait before Databricks validates bucket access when creating the storage credential / external location. Modeled with a `time_sleep` resource whose `triggers` cover both the trust policy and the identity policy JSON, so any future change to either re-triggers the wait.
- Databricks Free Edition's metastore has no default storage root, so each `databricks_catalog` needs an explicit `storage_root` under the external location's bucket — the UI's "Default Storage" option isn't available/used here since it would bypass the project's own S3 bucket.
- This org's Neon plan caps PITR history retention at 21600s (6h); `neon_project` defaults to 86400s (1 day) when unset, so it must be set explicitly.
- `neon_project` requires `org_id` for org-scoped Neon accounts (not optional as initially assumed).

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
