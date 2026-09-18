## Outcome (2026-09-18)

**The Access Group pattern as originally proposed below does not work on this
workspace/edition and was not fully implemented.** Unity Catalog grants resolve
principals against account-level identities; Free Edition's API only lets Terraform
create workspace-level groups (account-level API returns `Not Found`). Granting a
workspace-level group a UC privilege fails with `Could not find principal with name
...`, confirmed via direct CLI calls (not a Terraform-provider bug) against both a
brand-new group and a long-established one. See design.md's Outcome section for the
full investigation, including an unexplained account-level group
(`FG Platform Management`) discovered mid-investigation that *could* be granted —
evidence the mechanism needs account-level identities we don't have API access to.

What actually landed: the three Access Groups exist (kept as a structural
placeholder), `FG Data Ops` is a member of all three (also structural), but catalog
access is granted directly to the CI/CD service principal, same mechanism as
`phase1-identity-governance` already established. `identity-governance`'s
requirements are unchanged by this proposal — the "Modified Capabilities" section
below describes the original intent, not the outcome.

## Why

`phase1-identity-governance` gave the CI/CD service principal `USE_CATALOG` via a
direct `databricks_grants` resource per catalog. That doesn't scale — every future
principal needing catalog access would mean another grant block scattered through the
code. It's also the wrong module for it: that direct grant was written as a root-level
concern, but access governance and catalog structure are genuinely separate axes with
different change cadences — proven by the fact `databricks-unity-catalog` worked
correctly before any access concern touched it. This introduces Access Groups as the
standard access-governance layer: catalogs grant privileges to Access Groups, not to
individual principals; principals join the Access Group that matches the access they
need.

## What Changes (as implemented, see Outcome above)

- New module `modules/databricks-access-groups/`: one Access Group per catalog
  (no grant — see Outcome), single-instance, matching the
  `aws-s3`/`databricks-unity-catalog` module convention
- Root composes one Access Group per environment catalog: `AG Catalog mdp_dev READ`,
  `AG Catalog mdp_tst READ`, `AG Catalog mdp_prd READ`
- `FG Data Ops` becomes a member of all three Access Groups (structural, not
  functional — see Outcome)
- Catalog access remains a direct grant to `svc-cicd-github`, unchanged from
  `phase1-identity-governance`

## Capabilities

### New Capabilities
- `access-governance`: Access Groups exist, reserved for a future account-level
  migration; catalog access is granted directly for now (see spec for the actual
  requirements)

### Modified Capabilities
(none — `identity-governance` is unchanged; the direct-grant mechanism it established
remains in place)

## Impact

- Adds `databricks_group` (x3) resources (the Access Groups) and
  `databricks_group_member` (x3, `FG Data Ops` into each) to Terraform state, in a new
  module + root wiring
- The direct `databricks_grants.cicd_catalog_use` resources from
  `phase1-identity-governance` remain in place — briefly removed and restored during
  this change's investigation, net no change to the deployed mechanism
- No change to `unity-catalog` capability's own requirements — access governance is
  intentionally kept out of that module
