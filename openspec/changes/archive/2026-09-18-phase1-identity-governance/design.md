## Context

See proposal.md - Why. Phase 2 (`demo-databricks-mdp`) needs a CI/CD identity for
`bundle deploy`. Manually testing service principal creation via the workspace UI
showed a newly created SP is added to every existing group by default — a real,
observed behavior, not a hypothetical risk. This is the last convenient point to put a
minimal group structure in place before Phase 3+ adds more identities (human or
machine) that would otherwise inherit the same undifferentiated default.

## Goals / Non-Goals

**Goals:**
- A named place (group) for each of the three functional concerns this platform will
  eventually need identities for
- A CI/CD service principal Phase 2 can authenticate with, created and tracked as code
- Access scoped narrowly enough to deploy the (currently empty) bundle — not
  "whatever the workspace default happens to grant"

**Non-Goals:**
- Changing Terraform's own Databricks provider authentication (stays on
  `var.databricks_token`) — explicitly deferred, per direct instruction
- A Platform Engineering or Data Engineering service principal — no concrete workload
  needs one yet; those two groups stay empty until a real identity needs to join them
- Finalizing least-privilege catalog grants/entitlements for the CI/CD SP — starts
  minimal, tightened once Phase 3 gives it actual jobs/pipelines to run against

## Decisions

**Three functional groups now, only one populated.**
`FG Platform Engineering` (deployment/infra), `FG Data Engineering` (pipeline/job
execution), `FG Data Ops` (operational/cross-cutting — where the CI/CD SP lives for
now, alongside the workspace's current human user). Creating all three now costs
nothing and gives every future automation identity an intentional home instead of the
workspace's undifferentiated default; only `FG Data Ops` has a member today because
that's the only concrete need right now.
Alternative considered: create only `FG Data Ops` now, add the other two when Phase
3/6/7 need them — rejected because naming the full shape now costs nothing extra, and
doing it once here is cheaper than three separate small changes later.

**CI/CD SP lands in `FG Data Ops`, alongside the human account that manages it, not in
`FG Platform Engineering`, for now.**
Deploying a bundle reads as a platform-engineering concern, but this is intentionally
the coarse starting point: `FG Data Ops` holds the CI/CD SP (`svc-cicd-github`) and
`handsonessential@gmail.com` — the account whose PAT authenticates Terraform and that
created the SP — for now, accepting broader-than-ideal access in exchange for not
pre-guessing a narrower permission set before there's a real workload to derive it
from. Tightening (moving the SP to a narrower group, or granting per-catalog UC
permissions directly instead of via broad group membership) is deferred to when Phase
3 gives us something concrete to scope against.
Alternative considered: scope the SP to `FG Platform Engineering` with narrow, guessed
permissions today — rejected for the same "don't build for hypothetical requirements"
reasoning as the two empty groups above.

**Entitlements and grants determined empirically, not guessed upfront — no admin
grant.**
Databricks' own docs don't give a definitive list of what a CI/CD deploy SP needs, and
Free Edition's exact behavior here isn't something to assume. tasks.md includes a real
`bundle deploy --target dev` attempt using the SP's OAuth credential as the
verification step — a failure names exactly what's missing, and only that gets added.
Explicitly considered and rejected: adding `FG Data Ops` (or the SP directly) to the
built-in `admins` group. Databricks doesn't have a generic "admin entitlement" on a
custom group — the only way to grant admin here is that system-group membership,
which would give a GitHub Actions-controlled credential full workspace admin instead
of "can deploy this one bundle." Confirmed with the user (2026-09-18): stick with the
empirical, minimal-grant approach; revisit only if a real `bundle deploy` attempt
proves something narrower is insufficient.

**Terraform-managed, not UI-created.**
Matches the governance-ownership pattern Phase 1 already established (Terraform owns
Unity Catalog structure; this extends that to identity/group structure) — auditable in
git history, and avoids the "SP added to every group by default" surprise from the
manual UI test, since Terraform only adds the membership we declare.

## Risks / Trade-offs

- [`FG Data Ops` starting broad — the CI/CD SP has whatever access the workspace's
  current human user(s) also have via that group, more than `bundle deploy` on an
  empty bundle strictly needs] → Mitigation: logged here as an accepted starting
  point, not an oversight; revisit once Phase 3 gives us a concrete, narrower
  permission set to move to.
- [The OAuth client secret Terraform generates is a real, usable credential the moment
  it's created] → Mitigation: treated as a sensitive Terraform output only; Phase 2's
  task 2.3 moves it directly into GitHub Actions secrets, never a file or chat.
- [`FG Platform Engineering` and `FG Data Engineering` sit empty after this change,
  which could read as dead/unused config] → Mitigation: same reasoning as
  `deployment/single_workspace`'s placeholder in the prior change — documented here as
  deliberate and reserved, not speculative.

## Migration Plan

Net-new: no existing groups/SPs to migrate. Land the Terraform, apply (creates 3
groups + 1 SP + 1 secret + two group memberships — the SP and
`handsonessential@gmail.com`, both into `FG Data Ops`), capture the OAuth client
ID/secret as sensitive outputs, hand them to Phase 2's task 2.3 for GitHub Actions
secret storage. Rollback: destroy the new resources — nothing else in the workspace
depends on them yet, since Phase 2 hasn't consumed the credential in CI at the time of
rollback.
