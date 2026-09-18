See design.md's Outcome section for the full account of why this deviates
significantly from the plan below. Summary: Unity Catalog grants require
account-level identities, which Free Edition's API doesn't expose to Terraform;
workspace-level groups (all we can create) can never be granted a UC privilege here.
The Access Group *grant* mechanism was abandoned; the groups and membership structure
were kept.

## 1. Access Groups module

- [x] 1.1 Create `modules/databricks-access-groups/` with a `catalog_name` input, one
      `databricks_group` (`AG Catalog <catalog_name> READ`) — done. The planned
      `databricks_grants` resource was built, attempted, and ultimately removed: it
      failed on every apply with `Could not find principal with name ...` (see
      design.md Outcome) and can never succeed on this workspace, so shipping it would
      permanently block all future applies
- [x] 1.2 Output the group's `id` and `display_name` — done, both referenced from root

## 2. Root composition

- [x] 2.1 Add `module "access_groups"`, `for_each`'d over `var.environments`, wired to
      `module.unity_catalog[each.key].catalog_name` — done
- [x] 2.2 Remove `databricks_grants.cicd_catalog_use` (the direct grant from
      `phase1-identity-governance`) — done, then **restored** once the Access Group
      grant mechanism was confirmed unworkable (see design.md Outcome); net no change
      to the deployed access mechanism
- [x] 2.3 Add `databricks_group_member` resources — changed from the original plan
      (`svc-cicd-github` joining each Access Group directly) to `FG Data Ops` joining
      each Access Group instead, per the user's correction that this is the more
      idiomatic use of the FG/AG split (functional groups gain access by joining
      Access Groups, not individual principals). Kept even though it doesn't
      currently grant anything real — see design.md Outcome

## 3. Apply and verify

- [x] 3.1 Review the plan, apply — done, multiple times through the investigation;
      final state: `databricks groups get` on each `AG Catalog <name> READ` group
      lists `FG Data Ops` as its only member (no functional grant attached)
- [x] 3.2 Confirm the direct grants are gone — superseded: the direct grant to
      `svc-cicd-github` is back and is the real access mechanism (see 2.2). Verified
      via `databricks grants get catalog mdp_dev/tst/prd`: principal is the SP's
      `application_id`
- [x] 3.3 Re-run the same check used in `phase1-identity-governance`:
      `databricks bundle run hello_world --target dev` — succeeded (`TERMINATED
      SUCCESS`) after the direct grant was restored, confirming real access works

## 4. Documentation

- [x] 4.1 Update CLAUDE.md's "Identity & groups" section to document both group axes
      (`FG` functional, `AG` access), that `AG` groups are currently a reserved
      placeholder (not a working grant mechanism, per this change's Outcome), and
      that real catalog access is via direct grant until account-level group support
      is available
