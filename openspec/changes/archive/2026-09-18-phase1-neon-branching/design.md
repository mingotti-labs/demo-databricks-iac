## Context

See proposal.md - Why. Discovered mid-brainstorm for Phase 3's first ingestion
pattern (3a, Lakeflow Connect from Neon): the original design assumed a single Neon
instance and would have scoped ingestion to `mdp_dev` only, since there was nothing
else to point at. The user recalled Neon's branching feature; verified via the
installed provider's schema (`terraform providers schema -json`) rather than assumed:
`neon_branch`, `neon_endpoint`, and the `neon_branch_role_password` data source all
exist in the `kislerdm/neon` provider version already in use, and Neon's free tier
allows 10 branches/project — comfortably enough for this.

## Goals / Non-Goals

**Goals:**
- The Neon project's name reflects what it actually is (one platform-wide Postgres
  instance, not a dev-specific one)
- Real data separation between active development and the platform's stable data
  line, mirroring the git `main`/`dev` convention already used for code
- `neon-postgres` secret scope (and everything built on it, starting with Phase 3)
  targets `dev`, not `main`

**Non-Goals:**
- A `tst` or `prd` branch — not asked for; `main` covers the "stable" role for now.
  Revisit if a concrete need for a third branch shows up.
- Renaming Atlas to match — Atlas has no branching feature to mirror this pattern
  with, and wasn't part of the request. Accepted inconsistency, noted in proposal.md.
- Any change to what's *inside* the database (schema, tables) — this change is
  purely project/branch topology. Seed data and schema are Phase 3's job.

## Decisions

**`main` keeps its name; a new `dev` branch is added, not the other way around.**
Matches git exactly: a repository's `main` branch isn't renamed to "prod" to make it
the production line — it already is, by convention, without a rename. Renaming
`main` → `prod` here would actually undermine the git-mirroring intent (the label
"prod" would exist, but a future reader familiar with git would still expect a branch
called `main` and wonder where it went).
Alternative considered: rename the existing branch to `prod`, keep only two branches
named `prod`/`dev` — rejected as needlessly literal; "matching git" means matching
git's actual naming convention, not just conceptually having two branches.

**`main` is NOT protected — reverted after a real apply failure.**
The original intent was `default_branch_protected = true` on `main`, as the direct,
low-cost consequence of it holding the platform's stable/production-equivalent data.
First apply attempt failed: `BRANCHES_PROTECTED_LIMIT_EXCEEDED` — Neon's free tier
allows zero protected branches, a different quota from the "10 branches/project"
limit checked earlier (that one's about branch *count*, this one's specifically about
how many of them can be *protected*). Confirmed via the actual API error, not
assumed. Reverted; both branches are unprotected. Revisit only if the plan is ever
upgraded.

**Secret scope re-wired to `dev`, `main`'s connection exposed but unconsumed.**
Everything built from here forward (Phase 3's ingestion, seed data) should work
against `dev`, not the platform's one stable copy. `main`'s connection details are
still exposed as module outputs (`main_host` etc.) so a future consumer (e.g. a
`prd`-target ingestion pipeline, if that ever becomes a real requirement) doesn't
need the module touched again to use them — same "reserved, not built out" pattern as
`FG Platform Engineering`/`FG Data Engineering` in `phase1-identity-governance`.

**Neon project rename verified empirically, not assumed.**
The provider schema doesn't expose whether `name` forces replacement (Terraform's
`providers schema -json` output doesn't surface `ForceNew` for this provider). Rather
than guess, tasks.md includes a `terraform plan` review as its own step before
applying anything — if it forces replacement, that's still acceptable since Neon
holds no data yet (confirmed empty immediately before this change), but the plan
gets reviewed either way before `apply`.

## Risks / Trade-offs

- [Renaming the project might force full replacement (new project, new default
  branch, new credentials)] → Mitigation: Neon is confirmed empty; a full recreate
  loses nothing. Reviewed via `terraform plan` before applying regardless.
- [Atlas keeps the `mdp-dev` name, Neon becomes `mdp` — inconsistent naming between
  the platform's two source databases] → Mitigation: accepted and documented here;
  Atlas has no branching feature to justify the same restructuring, and renaming it
  to match wasn't requested.
- [Neither Neon branch is protected — `main` (the stable/production-equivalent data
  line) can be deleted as easily as `dev`] → Mitigation: not fixable on the current
  Neon plan (confirmed: zero protected branches on free tier). Accepted; be
  deliberate before running any destructive operation against `main`.
- [`main`'s connection is now exposed but has no consumer] → Mitigation: same
  reasoning as other deliberately-reserved outputs this project already has; not
  dead code, a documented placeholder for a real future need.

## Migration Plan

1. Update `modules/neon` (rename input, restructure outputs, add the `dev` branch +
   endpoint + password lookup).
2. Update root wiring: `neon` module call (`project_name = "mdp"`), `secret_scopes`
   module call (source from `module.neon.dev_*` instead of the old unprefixed
   outputs).
3. `terraform plan`, review carefully (rename behavior included), apply.
4. Verify: `neon_branches` data source (or Neon console) shows `main` and `dev`;
   `databricks secrets get-secret neon-postgres host` (or similar) resolves to the
   `dev` branch's endpoint, not `main`'s.

Rollback: destroy the `dev` branch/endpoint (clean, no data loss elsewhere) and
revert the project rename / secret-scope wiring. Nothing downstream consumes any of
this yet (Phase 3 hasn't started), so there's no cascading impact to unwind.
