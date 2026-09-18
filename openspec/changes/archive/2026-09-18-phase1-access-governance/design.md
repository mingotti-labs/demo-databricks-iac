## Context

While verifying `phase1-identity-governance`'s CI/CD service principal against a real
job, a direct `databricks_grants` resource was added at the root, granting
`USE_CATALOG` straight to the SP on each catalog. The user flagged two things: this
doesn't scale (proliferation of individual grants as more principals arrive), and
separately, that catalog structure and access governance are different concerns —
proven by the fact `databricks-unity-catalog` worked correctly before any access
concern touched it. This change introduces the Access Group pattern to fix both:
indirection through groups instead of per-principal grants, in a module dedicated to
governance rather than structure.

## Goals / Non-Goals

**Goals:**
- Catalog-level read access is granted to a group, never directly to an individual
  principal
- Adding a new principal's catalog access becomes "add to group," not "write a new
  grant"
- Access governance lives in its own module, decoupled from catalog structural
  provisioning

**Non-Goals:**
- Schema- or table-level grants, or a WRITE-tier Access Group — no concrete need yet
  (nothing writes data; Phase 3 will define what a write tier actually requires)
- Migrating `FG Data Ops` or the functional-group model — Access Groups are a
  different axis (what you can access) from Functional Groups (what function you
  serve); both exist, neither replaces the other

## Decisions

**One Access Group per catalog, named `AG Catalog <name> READ`.**
Mirrors the `FG <Name>` naming convention already established, but on the access axis
instead of the functional axis. "READ" names the tier (`USE_CATALOG` is the floor of
any read access) and leaves room for a distinct `AG Catalog <name> WRITE` later
without conflating grant levels inside one group.

**New module, not folded into `databricks-unity-catalog`.**
Rejected the initially-proposed plan (Access Group creation inside the catalog
module) per direct feedback: catalog structure and access governance are separate
concerns with different change cadences — access changes far more often than catalog
definitions, and bundling them would force every future access change to touch a
module whose job is catalog provisioning. `databricks-access-groups` is
single-instance (one catalog in, one Access Group + grant out), called once per
environment from the root, same shape as `aws-s3` and `databricks-unity-catalog`.

**Membership, not grants, at the root.**
The root now creates `databricks_group_member` resources connecting
`svc-cicd-github` to each of the three Access Groups, replacing the three direct
`databricks_grants.cicd_catalog_use` resources added earlier. Net effective access is
unchanged for the SP today; what changes is that the *next* principal needing catalog
read access is one membership resource, not a new grant block.

## Risks / Trade-offs

- [Access Groups currently have exactly one member each (the SP) — for a single
  principal, this is more resources than a direct grant would need] → Mitigation:
  accepted deliberately; the point is the shape holding up as more principals arrive,
  not minimizing resource count today.
- [Two group axes now exist (`FG` functional, `AG` access) — a future reader needs to
  know the distinction] → Mitigation: documented in CLAUDE.md's "Identity & groups"
  section as part of this change's tasks.

## Migration Plan

Real Terraform state change: destroy 3 `databricks_grants.cicd_catalog_use`
resources, create 3 `databricks_group` + 3 `databricks_grants` (the Access Group's
own grant) + 3 `databricks_group_member` resources. No data or downstream consumer
depends on the direct-grant mechanism (Phase 3 hasn't started), so this is a clean
swap, verified by re-running `databricks bundle run hello_world` against all three
targets after the swap — the exact same check used the first time.

## Outcome (2026-09-18)

The migration above did not complete as planned. Applying `module.access_groups`'s
`databricks_grants.read_access` (the Access Group's own grant) failed on all three
catalogs: `Could not find principal with name "AG Catalog mdp_dev READ"` (etc.). The
`databricks_group` resources themselves were created successfully — only the grant
failed.

**Investigation, in order:**
1. Assumed a propagation delay (new group not yet visible to the grants API) — same
   class of issue `modules/aws-s3` already works around with `time_sleep`. Added a
   15s `time_sleep` between group creation and the grant. Same error.
2. Tested against `FG Data Ops` instead — a group that had existed for many minutes,
   ruling out propagation delay entirely. Same error, via a direct
   `databricks grants update catalog mdp_dev --json ...` CLI call (not a
   Terraform-provider bug).
3. Per the user's suggestion, switched the design so `FG Data Ops` (not the SP
   directly) would be the Access Group member — a cleaner use of the FG/AG pattern
   regardless of the grant issue. Still failed identically once actually applied.
4. The user tested granting via the Databricks UI directly (Catalog Explorer →
   Permissions → Grant on `mdp_dev`), including in an incognito window to rule out
   browser autofill contamination. Typing `FG` or `AG` in the principal search
   surfaced exactly one match: `FG Platform Management` — a name that does not
   appear in `databricks groups list`, `databricks users list`, or
   `databricks service-principals list` (checked directly, not assumed). The user
   was able to grant `USE_CATALOG` to it via the UI, and `databricks grants get`
   confirmed the grant existed with that literal principal string.
5. `databricks account metastores list` returns `Not Found` — confirms no
   account-level API access is available to us on Free Edition.

**Conclusion:** Unity Catalog's grants system resolves principals against
account-level identities. `FG Platform Management` is very likely a pre-existing
account-level group (unrelated to anything this project created — nothing in this
repo's Terraform could produce that name), resolvable by UC because it's
account-level; our Terraform-created `databricks_group` resources are workspace-level
only (the sole kind Free Edition's API exposes to us) and are therefore invisible to
UC's grant resolution, regardless of propagation time or which principal joins the
group. This is a platform/edition constraint, not something fixable from Terraform or
the CLI.

**Resolution:** Reverted to `phase1-identity-governance`'s direct-grant mechanism
(`databricks_grants.cicd_catalog_use`, principal = the SP's `application_id`) as the
real, working access path. Removed the `databricks_grants.read_access` resource from
`modules/databricks-access-groups` (it can never succeed here) but kept the
`databricks_group` resources themselves and `FG Data Ops`'s membership in them,
per explicit instruction — reserved as a structural placeholder for a possible future
account-level migration, not a working mechanism today. The unexplained
`FG Platform Management` grant on `mdp_dev` was no longer present when checked again
shortly after — its origin and current membership remain unresolved; flagged for the
user to investigate via the Account Console (out of reach from here) before this
project grants it anything else.
