## Context

See proposal.md - Why. Phase 1 is implemented and archived (`archive/2026-09-15-phase1-core-infrastructure`) with real state in the HCP Terraform workspace `demo-databricks-iac`, working directory `envs/dev`. No downstream phase has written data yet — Phase 2 (`demo-databricks-mdp`) is still an open, unimplemented proposal (`phase2-dab-cicd`). This is the last point in the project where restructuring Phase 1 is free of data-migration risk.

## Goals / Non-Goals

**Goals:**
- Each environment catalog (`mdp_dev`/`tst`/`prd`) gets its own bucket, IAM role, storage credential, and external location
- The deployment root's name and location communicate what it actually is: the one Free-Edition, single-workspace deployment
- Modules are reusable by a future second deployment root without duplication

**Non-Goals:**
- Building out `deployment/single_workspace/` or `deployment/multiple_workspaces/` — they stay empty (`.gitkeep` only) until a real need exists. This change only reserves their place in the structure.
- Changing anything about Neon, Atlas, or secret scopes — untouched by this change.
- Revisiting the bronze/gold schema set or naming — unchanged, still per `CLAUDE.md`.

## Decisions

**Three buckets, one per catalog, over one shared bucket with prefix isolation.**
UC catalog-level ACLs already isolate access logically, but the storage layer didn't isolate at all — one IAM role could read/write all three catalogs' data. A real client engagement would not let a compromised or misconfigured prd credential touch dev/tst data, or vice versa. Splitting now (before Phase 3 writes anything) costs two extra free-tier S3 buckets and IAM roles and avoids a much harder migration once tables exist.
Alternative considered: keep the shared bucket, rely on UC ACLs alone — rejected as the weaker pattern to have as a portfolio artifact, and Phase 1 is the cheapest point to fix it.

**Module composition: single-instance modules, multiplicity via root-level `for_each`.**
`aws-s3` already takes one `bucket_name` per call and needs no change. `databricks-unity-catalog` currently takes a *list* of catalog names and internally `for_each`s one shared credential/location across them — that's the coupling that caused the shared-bucket problem in the first place. It changes to take one `catalog_name`, one `bucket_name`, one `iam_role_arn` per call (still `for_each`ing its own 9 schemas internally, which is unrelated multiplicity). The root (`deployment/free_workspace/main.tf`) then declares one `environments` map and `for_each`s both the `aws_s3` and `unity_catalog` module calls over it.
Alternative considered: keep the multi-catalog-aware module shape, add a `buckets` map input instead of a single `bucket_name` — rejected because it keeps the "N catalogs, N buckets" coupling inside the module instead of letting the root compose it, which is exactly what makes the module unusable by a future deployment root that might want a different N (e.g. `multiple_workspaces` wanting one catalog per real workspace, not three catalogs in one call).

**Deployment folder: `deployment/<shape>/`, not `envs/<name>/`.**
`envs/dev` implied a per-environment root that doesn't exist on Free Edition — there is exactly one deployment, and it produces all three catalogs. Renaming to `deployment/free_workspace/` names the actual constraint driving this root's shape (Free Edition: serverless-only, no account-level API, single metastore), and reserves two sibling placeholders for shapes that aren't built yet:
- `deployment/single_workspace/` — a future *paid* single workspace, not Free-Edition-constrained (could use classic clusters, account-level API)
- `deployment/multiple_workspaces/` — the roadmap Appendix A corporate pattern: real separate workspaces per environment
Both stay as empty folders with `.gitkeep` — no code, just a documented slot, consistent with not building for hypothetical requirements.
Alternative considered: keep `envs/` as the top-level name and just rename the one folder inside it (e.g. `envs/single-workspace/`) — rejected because `envs/` itself carries the same "per-environment" implication this change is trying to remove; `deployment/<shape>/` names the axis that actually varies (workspace topology), not environments.

**Modules promoted to top-level `modules/`.**
Currently nested under `envs/dev/modules/`, unreachable from any other root by a sane relative path. Moving to `modules/` at repo root lets `deployment/free_workspace/main.tf` (and eventually `deployment/multiple_workspaces/<workspace>/main.tf`) reference the same `../../modules/*` (or `../modules/*`, depending on nesting depth) without duplication.
No alternative seriously considered — this is the standard Terraform layout for a repo expecting more than one root module.

**Migration: destroy and recreate, not `terraform state mv`.**
Moving `neon`, `atlas`, and `secret_scopes` module source paths and the deployment root folder is free — Terraform resource addresses are keyed by module call name in the root config, not by file location, so those three modules' state is untouched by the move itself. `aws_s3` and `unity_catalog` are different: their root-level call shape changes (single call → `for_each` over a map), and `unity_catalog`'s internal resource shape changes too (module signature change, not just an address change), so a clean `state mv` isn't practical for those two. Since no data exists yet, destroying the current bucket/credential/location/catalogs and applying fresh is simpler and equally safe.
Alternative considered: `terraform state mv module.aws_s3 'module.aws_s3["dev"]'` to preserve the existing `hoe-mdp-dev` bucket and skip its recreation — technically possible since the `aws-s3` module itself doesn't change shape, but rejected for consistency: `unity_catalog` must be destroyed/recreated regardless (its module signature changed), and the bucket has no data in it, so partially preserving one bucket via state surgery adds risk for no real benefit.

## Risks / Trade-offs

- [Bucket names `hoe-mdp-tst` / `hoe-mdp-prd` must be globally unique in S3 across all AWS accounts, not just this one] → Mitigation: verified at `terraform apply` time as part of tasks.md; same naming scheme as the already-successful `hoe-mdp-dev` makes a collision unlikely but not impossible.
- [Destroying the existing storage credential/external location briefly leaves the three catalogs without a working `storage_root` mid-migration] → Mitigation: no tables exist in any catalog yet (Phase 3 hasn't started), so there is nothing reading through them during the transition; do the destroy/apply in one focused session rather than leaving it half-done.
- [HCP Terraform's working-directory setting is a UI/API setting, not something committed to the repo] → Mitigation: call it out explicitly as a manual task in tasks.md so it isn't silently missed after the folder rename.

## Migration Plan

1. Refactor modules and repo layout (`modules/` promotion, `deployment/free_workspace/` rename, placeholder folders) — no cloud impact, verified with `terraform plan` showing only the expected destroy/create set once the root composition changes.
2. Update the HCP Terraform workspace's working directory to `deployment/free_workspace`.
3. Apply: destroys the current single bucket/role/credential/location/catalogs/schemas, creates the three-bucket structure fresh, including the two-pass `uc_external_id` hardening per environment.
4. Rollback: since this is destroy-then-recreate with no data, rollback is reverting the branch and re-applying the prior `envs/dev` structure against the same HCP Terraform workspace (also requires reverting the working-directory setting).
