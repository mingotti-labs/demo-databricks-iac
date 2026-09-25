# CLAUDE.md — demo-databricks-iac

Conventions for AI-assisted development on this Terraform infrastructure repo.
This file captures repo-specific decisions; general coding standards are in the
global ~/.claude/CLAUDE.md.

## Platform context

- Databricks Free Edition (serverless compute only, single workspace)
- One Databricks metastore serving all environment catalogs
- AWS-hosted: object storage, Neon Postgres, MongoDB Atlas
- Remote state: HCP Terraform (org `hands-on-essential-mingotti`, workspace
  `demo-databricks-iac`)

## Repository structure

- `modules/`: shared, single-instance Terraform modules (one bucket per call, one
  catalog per call, etc.) — multiplicity is composed at the root, not inside a module.
- `deployment/free_workspace/`: the one real deployment root today (Free Edition:
  single workspace, serverless-only, no account-level API).
- `deployment/single_workspace/`, `deployment/multiple_workspaces/`: reserved,
  empty (`.gitkeep` only) placeholders for future deployment shapes (a future paid
  single workspace, and the corporate multi-workspace pattern respectively) — do not
  build these out until there's a real need.

## Naming conventions

@NAMING.md

## Identity & groups

Both group axes (naming: see NAMING.md) are Terraform-managed — add members by
editing the relevant module, not the workspace UI:
`modules/databricks-identity-governance/` (functional groups),
`modules/databricks-access-groups/` (Access Groups).

`AG Catalog <name> READ` groups are **currently a reserved placeholder, not a
working grant mechanism** — Unity Catalog grants resolve principals against
account-level identities, and Free Edition's API only lets Terraform create
workspace-level groups, so granting one fails with `Could not find principal with
name ...` (confirmed empirically, not a bug in this repo's code; see the
`phase1-access-governance` change's design.md for the full investigation). Real
catalog access is a direct `databricks_grants` to the principal for now, same
mechanism `phase1-identity-governance` established.

New service principals should NOT be added to the built-in `admins` group without a
specific, evidenced reason (see the `phase1-identity-governance` change's design.md
for why).

### CI/CD service principal pipeline execution

The CI/CD SP needs more than `USE_CATALOG` to actually run a pipeline —
`BROWSE` on the catalog (cluster initialization) and `USE_SCHEMA` +
`CREATE_TABLE` on its target schema (creating/writing its managed table) are
both required, granted across every bronze schema up front
(`databricks_grants.cicd_catalog_use`/`cicd_schema_use`). Both were discovered
via real pipeline run failures, not anticipated — see
`phase3b-cicd-pipeline-grants`'s design.md.

**`CREATE_MATERIALIZED_VIEW` is a separate UC privilege from
`CREATE_TABLE`** — `CREATE_TABLE` does not cover Materialized Views,
confirmed via a real pipeline run failure (`PERMISSION_DENIED: User does
not have CREATE MATERIALIZED VIEW on Schema 'mdp_dev.bronze_acnc'`) and via
the Terraform provider's own privilege enum. There is no equivalent
separate privilege for Streaming Tables — those fall under `CREATE_TABLE`,
which is why Neon's and clickstream's Streaming-Table pipelines never hit
this. Granted alongside `USE_SCHEMA`/`CREATE_TABLE` in the same
`cicd_schema_use` grant — see `phase3d-cicd-materialized-view-grant`'s
design.md.

A job/pipeline's execution identity (`run_as_user_name`) is a property of the
resource itself, not of whoever triggers the run — a sufficiently-privileged
human can trigger a CI/CD-SP-owned resource via CLI/API and it still executes
(and fails, or succeeds) under the SP's own permissions. No local
machine-to-machine credentials are needed to run something "as" the SP; just
target that resource's ID directly.

**Deleting a Lakeflow Declarative Pipeline deletes its managed tables by
default** (confirmed via Databricks' own docs — a beta `cascade=false` option
exists to keep them, but its reattachment mechanics aren't well-documented
enough to rely on). This is why the CI/CD SP's dev-prefixed pipeline/job
copies (`[dev svc_cicd_github] ...`) are the canonical, durable ones for this
project — the human-identity dev copies (`[dev handsonessential] ...`) are
disposable personal-iteration artifacts, safe to delete without losing
anything real, and should never be relied on to hold real data.

## Source databases

Naming: see NAMING.md.

- **Neon Postgres** (`modules/neon/`): `main` (stable/production-equivalent data
  line, no rename needed — same as git's `main` not being renamed to "prod") and
  `dev` (forked from `main`, where active development and downstream ingestion
  work happens). The `neon-postgres` secret scope points at **`dev`**, not `main`.
  Neither branch is protected — Neon's free tier doesn't support protected branches
  (`BRANCHES_PROTECTED_LIMIT_EXCEEDED`, confirmed via a real apply attempt); be
  deliberate before any destructive operation against `main`.
- **MongoDB Atlas** (`modules/atlas/`): no branching feature to mirror the Neon
  pattern with, so the naming inconsistency between the two source databases (see
  NAMING.md) is accepted rather than "fixed" to match.

## UC Connections

Naming: see NAMING.md.

- **`neon_dev`** (`modules/databricks-uc-connection-postgres/`): points at Neon's
  `dev` branch. Consumed by `phase3a-lakeflow-connect-neon` in
  `demo-databricks-mdp` — its ingestion pipeline references this connection by
  name. No `sslmode` option — this connection type doesn't support one (confirmed
  via a real apply rejection); Neon negotiates SSL on its own. To verify
  connectivity to any UC Connection, `SHOW SCHEMAS IN CONNECTION <name>` is not
  valid syntax — use a temporary `CREATE FOREIGN CATALOG ... USING CONNECTION`,
  browse it, then drop it (see `phase3a-neon-uc-connection`'s tasks.md for the
  exact commands).

## UC Volumes

Naming: see NAMING.md.

- **`s3_clickstream_raw`** (`modules/databricks-uc-volume/`): one `MANAGED`
  volume per environment, inside that environment's `bronze_clickstream`
  schema. Consumed by `phase3b-clickstream-autoloader` in `demo-databricks-mdp`
  — its Auto Loader pipeline reads synthetic clickstream files from this
  volume's path. Multi-env from the start (unlike `neon_dev`), since the
  source data is entirely synthetic — each environment generates and lands its
  own independent data. Storage reuses each environment's existing bucket (the
  same one backing that catalog's `storage_root`) — no new bucket, storage
  credential, or external location. Whether the CI/CD service principal needs
  an explicit grant to read/write it (beyond the existing catalog-level
  `USE_CATALOG` grant) was left unverified here — see
  `phase3b-clickstream-volume`'s design.md.

## Bronze schema shape

Each source system gets exactly two bronze-family schemas: `bronze_<source>`
(raw, source-faithful landing) and `bronze_<source>_publish` (governed — SCD1/
SCD2 tables, and future row/column security). There is deliberately no
`bronze_<source>_history` schema — Phase 1 reserved one per source
(`bronze_neon_history`, `bronze_atlas_history`) for full change-history/CDC
replay, but both sat empty (confirmed via `databricks tables list` before
removal), and that purpose is now served by `<table>_scd2` tables inside
`_publish` instead — more directly queryable than a raw history table would
have been. See `phase3b-bronze-schema-simplification`'s design.md for the full
reasoning. SCD1/SCD2 tables themselves are built in `demo-databricks-mdp`, not
here — this repo only provisions the schema.

**`bronze_ungm`/`bronze_ungm_publish`** (Phase 3c, UNGM UNSPSC API): the
smallest source-system onboarding so far — the UNGM public API needs no
credential, connection, or volume, just the schema pair. Consumed by an
upcoming `demo-databricks-mdp` change. CI/CD SP schema-level grants
(`USE_SCHEMA`/`CREATE_TABLE`) applied proactively this time, not
discovered via a failure — see "CI/CD service principal pipeline
execution" above.

**`bronze_acnc`/`bronze_acnc_publish`** (Phase 3d, ACNC Charity Register):
same shape as UNGM's — data.gov.au's public CKAN Data API needs no
credential, connection, or volume either, just the schema pair. Consumed
by an upcoming `demo-databricks-mdp` change (a reusable custom PySpark
Data Source connector, not a one-off fetch helper like UNGM's). CI/CD SP
schema-level grants applied proactively, same as UNGM's.

**`bronze_nsw_spatial`/`bronze_nsw_spatial_publish`** (Phase 3f, NSW
Spatial Services): named after the publishing system (NSW Spatial
Services), not the specific dataset (its "Property" layer) — matches how
every other bronze schema names a source system, not a dataset within it.
Same shape as ACNC's — the Esri ArcGIS REST FeatureServer needs no
credential, connection, or volume. Consumed by an upcoming
`demo-databricks-mdp` change (a second reusable custom Spark Data Source
connector, generic over ArcGIS FeatureServer layers). CI/CD SP
schema-level grants, **including `CREATE_MATERIALIZED_VIEW` from the
start** (that gap was discovered reactively for ACNC — see "CI/CD service
principal pipeline execution" above — applied proactively here instead).

**`bronze_airroi`/`bronze_airroi_publish`** (Phase 3h, AirROI market
intelligence): this project's **first source with a real, paid,
authenticated API** — every prior source is either free/public or a
Phase-1-provisioned source-database credential. No free sandbox exists;
every call costs real money, so `demo-databricks-mdp`'s ingestion design
deliberately minimizes call volume (a handful of fixed markets, no
per-environment row-limiting the way ACNC/NSW property have, since there's
no free-tier concept to exploit). CI/CD SP schema-level grants, including
`CREATE_MATERIALIZED_VIEW` from the start.

**`bronze_iso`/`bronze_iso_publish`** (Phase 3i, ISO 3166 country/subdivision
reference data): same shape as UNGM's — the public, unauthenticated
`raw.githubusercontent.com` CSV mirror needs no credential, connection, or
volume, just the schema pair. Consumed by `demo-databricks-mdp`'s
`phase3i-iso-country-reference-ingestion` (merged and archived). CI/CD SP
schema-level grants applied proactively, including `CREATE_MATERIALIZED_VIEW`
from the start, same as NSW Spatial's and AirROI's. Was sequenced to land
**before** `phase3j-geonames-schema`, which modifies the same "Bronze and
gold schemas per catalog" requirement and assumes this one's schema list is
already the baseline — that ordering held (this change archived first).

**`bronze_geonames`/`bronze_geonames_publish`** (Phase 3j, GeoNames
country/admin1/admin2/city gazetteer data): same shape as ISO's — the
public, unauthenticated `download.geonames.org` dump-file mirror needs no
credential, connection, or volume, just the schema pair. Consumed by an
upcoming `demo-databricks-mdp` change
(`phase3j-geonames-reference-ingestion`, already drafted — see its PR).
CI/CD SP schema-level grants applied proactively, including
`CREATE_MATERIALIZED_VIEW` from the start.

## Silver schema shape

`phase4a-silver-landing-schemas` added `silver_landing_neon`,
`silver_landing_clickstream`, `silver_landing_ungm`, `silver_landing_acnc`,
`silver_landing_nsw_spatial`, and `silver_landing_airroi` — one schema per
source, mirroring the bronze schema-per-source pattern rather than the
domain-based `silver_<domain>` shape NAMING.md still reserves for Domain/
Marts (still TBD). CI/CD SP grants (`USE_SCHEMA`/`CREATE_TABLE`/
`CREATE_MATERIALIZED_VIEW`) applied proactively, same as NSW Spatial's and
AirROI's bronze schemas, since every Silver Landing table is a Materialized
View. Consumed by `demo-databricks-mdp`'s `phase4a-silver-landing` change.
No secret scope, connection, or volume needed — these schemas only hold
tables read from Bronze Publish, already provisioned.

`phase4b-silver-landing-iso-geonames-schemas` added `silver_landing_iso`
and `silver_landing_geonames` — same shape, for the two sources onboarded
after `phase4a`'s original six. Consumed by an upcoming
`demo-databricks-mdp` change (`phase4b-silver-landing-iso-geonames`).

## Secret scopes

- **`neon-postgres`**, **`atlas-mongodb`** — Phase 1 source-database
  connection credentials, provisioned by their own Terraform modules
  (`modules/neon/`, `modules/atlas/`), threaded into
  `modules/databricks-secret-scopes/` as module outputs.
- **`airroi`** (Phase 3h) — this project's **first external credential
  with no provisioning submodule of its own**. The API key was obtained
  manually (self-serve signup + $10 credit deposit at
  `airroi.com/api/developer`, no Terraform-manageable resource exists for
  this) and set directly as a `sensitive` HCP Terraform workspace
  variable (`airroi_api_key`) — never passed through a coding session,
  never in a `.tfvars` file. Threaded into
  `modules/databricks-secret-scopes/` as a root-level variable, not a
  module output, since there's no upstream module that produces it.
  - **This is also the first secret scope needing an explicit CI/CD SP
    grant** — confirmed via a real `prd` pipeline run failure
    (`dbutils.secrets.get("airroi", "api_key")` failed with a
    `SecretManagerClient` error; `databricks secrets list-acls airroi`
    showed only the human account's `MANAGE`, nothing for the CI/CD SP).
    `neon-postgres`/`atlas-mongodb` never hit this because their secrets
    back Terraform-managed UC Connections, never read directly by
    pipeline code — `dbutils.secrets.get()` is a genuinely different
    access path from a UC Connection, needing its own grant
    (`databricks_secret_acl`, `READ`, not the schema-level
    `databricks_grants` mechanism). See
    `phase3h-airroi-cicd-secret-grant`'s design.md.

## Workspace Git Folders

Both this repo and `demo-databricks-mdp` are cloned into the Databricks workspace
as Git Folders (`modules/databricks-git-repo/`), at `/Repos/Shared/<repo-name>` —
not a personal `/Repos/<user>/<repo-name>` path (the provider's default if `path`
is left unset). Terraform-managed like everything else here, not the
`databricks repos create` CLI or the workspace UI. Browse/dev convenience only —
no auto-pull-on-push; nothing in either bundle or Terraform pipeline reads from
these paths.

## Workflow

@CONTRIBUTING.md

Non-trivial changes go through OpenSpec first: propose (`openspec change new <name>`),
agree the spec, implement, archive. See `openspec/` and each change's `design.md` for
the decision record behind what's built.

## Running Terraform locally

`environment` and `uc_external_ids` have no persisted value in the HCP
Terraform workspace — they must be passed explicitly on every local
`plan`/`apply` (`-var="environment=dev" -var='uc_external_ids={"dev":"...",
"tst":"...","prd":"..."}'`, current values via `terraform output -json
uc_external_ids`). Omitting `uc_external_ids` doesn't just no-op — it plans to
*strip* the `sts:ExternalId` condition from each environment's IAM trust
policy (reverting to the variable's empty default), a real security downgrade
that looked like unrelated drift the first time it was hit. Always read the
full plan output for unexpected changes/destroys before applying, even when
the change you're making is purely additive.

## Guardrails — never do without explicit confirmation

- No account-level Terraform resources (Free Edition scope is workspace-level only)
- No destructive `terraform apply`/`destroy` against real state without walking through
  the plan output and getting explicit go-ahead first
- No secrets committed — sensitive variables live in the HCP Terraform workspace
  variable set only, never in a `.tfvars` file (see `.gitignore`)
