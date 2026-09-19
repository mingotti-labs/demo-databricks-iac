## Context

See proposal.md - Why. This is the second UC governance object family this repo
adds specifically for ingestion, after `uc-connections` (pull-based DB/SaaS
credentials, `phase3a-neon-uc-connection`). This one is for file-drop/push-style
ingestion (Auto Loader) instead. Unlike `neon_dev`, which is deliberately
dev-only (only one Neon branch feeds it), this pattern is multi-env from the
start — the clickstream source is entirely synthetic, so each environment
generates and lands its own independent data at zero marginal cost; there's no
single upstream system to scope against.

## Goals / Non-Goals

**Goals:**
- A managed Volume, one per environment, governed independently per source
  system (not shared across sources)
- Reuse existing per-env bucket infrastructure — zero new cloud resources
- Reusable module shape, in case a second file-drop source is ever needed

**Non-Goals:**
- The path structure inside the volume (data-source subfolder, `landing/`
  convention) — that's `demo-databricks-mdp`'s bundle/pipeline concern, not this
  repo's, beyond providing the volume itself
- A shared, multi-source-system volume — considered and rejected (see Decisions)
- Pre-emptive `READ VOLUME`/`WRITE VOLUME` (or `USE_SCHEMA`) grants for the
  CI/CD service principal — whether the existing catalog-level `USE_CATALOG`
  grant is sufficient, or whether volume-level access needs its own explicit
  grant the way `neon_dev`'s `USE_CONNECTION` did, is unverified. Per this
  project's evidence-before-fix convention, that gap (if real) surfaces from an
  actual failure in `phase3b-clickstream-autoloader`'s deploy/run, not from
  guessing ahead of time — see Risks below.

## Decisions

**New module, not an inline root resource.**
Same rationale as `databricks-uc-connection-postgres`: every piece of this
repo's infrastructure lives in a module composed at the root, and a generic
module means a future second file-drop source doesn't require touching this
one's internals.

**Managed volume, not external.**
A `MANAGED` volume's storage is auto-assigned by Databricks under the catalog's
existing `storage_root` — exactly the "reuse the existing bucket, no new
storage credential or external location" outcome this change is after. An
`EXTERNAL` volume would require its own `storage_location`, reintroducing the
per-source-system bucket/credential proliferation this design deliberately
avoids.

**One volume per source system — considered and rejected a single shared
multi-source volume.**
A shared volume (one generic landing volume for all present and future
file-drop sources) would mean less Terraform per new source added later, but
UC access grants (`READ VOLUME`/`WRITE VOLUME`) are scoped per volume — sharing
one across sources means no principal can be granted access to just one
source's files without also reaching every other source sharing that volume.
That directly undermines the reason `bronze_neon`/`bronze_atlas` are already
separate schemas rather than one shared source-agnostic schema. Rejected in
favor of one volume per source system, living inside that source's own
`bronze_<source>` schema — consistent with the existing precedent, and, per
direct instruction, not considered a meaningful implementation burden ("not
such a big deal to create several volumes anyway").

**Volume name: `s3_clickstream_raw`.**
Pattern `<service>_<source-system>_raw`, decided directly with the user. `s3`
names the physical service this volume's storage sits on — if a future
file-drop source ever lands on a different provider (e.g. Cloudflare R2, a UC
Volume type confirmed supported via `databricks_storage_credential`'s
`cloudflare_api_token` block, but deliberately out of scope for this change),
that volume's name would say `r2_...` instead, keeping the two visually
distinguishable in Catalog Explorer even though both are ordinary UC Volumes.

**Multi-env (dev/tst/prd) from day one.**
Deliberate divergence from `neon_dev`'s dev-only precedent. `neon_dev` is
dev-only because only one real Neon branch exists to point at; clickstream data
is entirely synthetic, so there's no equivalent constraint — each environment
independently generates and lands its own data, so the schema and volume are
created via the existing `for_each = var.environments` pattern already used
everywhere else in this repo, not special-cased the way `neon_dev` was.

## Risks / Trade-offs

- [Reusing the shared per-env bucket means the clickstream volume's storage
  sits alongside `bronze_neon`/`bronze_atlas`'s managed tables in the same
  physical bucket] → Mitigation: UC's schema/volume-level ACLs, not bucket-level
  IAM, are the actual governance boundary here — the same trade-off Phase 1
  already accepted for `bronze_neon`/`bronze_atlas` coexisting in one bucket; no
  new risk introduced.
- [A `MANAGED` volume's physical path under the bucket is assigned by
  Databricks, not hardcoded by this module] → Mitigation: `mdp`'s Auto Loader
  pipeline reads/writes via the standard `/Volumes/<catalog>/<schema>/<volume>/`
  UC path convention, not a raw S3 URI — consistent with how every other UC
  object in this platform is already referenced by name, not physical location.
- [The CI/CD service principal may lack the grants it needs to read/write this
  volume once `phase3b-clickstream-autoloader`'s job/pipeline actually try —
  volume-level access is unverified territory, unlike catalog/schema access
  which `bronze_neon` ingestion already proved works via `USE_CATALOG` alone]
  → Mitigation: verify empirically once that change deploys a job that writes
  into the volume; if it fails on a permission error, add the specific grant
  the error names (same discovery path as `neon_dev`'s `USE_CONNECTION` grant),
  not a speculative grant added now.

## Migration Plan

Net-new. Apply, confirm three volumes exist (one per environment) and are
empty, then hand off to `phase3b-clickstream-autoloader` in `demo-databricks-mdp`.
Rollback: destroy the volumes — nothing consumes them until that change is
built, so no cascading impact if this needs to be redone (same pattern as
`neon_dev`'s design.md).
