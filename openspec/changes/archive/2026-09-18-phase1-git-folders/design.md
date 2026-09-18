## Context

See proposal.md - Why. First attempt used `databricks repos create` directly
(CLI), landing both repos under `/Repos/handsonessential@gmail.com/<name>` — the
personal-folder default. Two problems, both raised directly: not Terraform (every
other workspace object this project owns is code, this shouldn't be an exception),
and the wrong location (personal folder, not the shared `/Repos/Shared/<name>` root).
Both CLI-created repos were deleted; this change redoes it as code.

## Goals / Non-Goals

**Goals:**
- Both repos browsable in-workspace at a shared, predictable path
  (`/Repos/Shared/<repo-name>`), not tucked under one user's personal folder
- Provisioned via Terraform, consistent with everything else this repo owns

**Non-Goals:**
- Two-way sync / auto-pull-on-push automation — this just clones and tracks
  `main`; keeping it current is a manual `git pull` in the Git Folders UI (or a
  future change, if that friction turns out to matter)
- A `git_credential_id` — not needed, both repos are public

## Decisions

**New module, not inline resources.**
Matches every other single-instance thing in this repo (identity groups, the UC
Connection, etc.) — one module, composed twice at the root, rather than two
near-duplicate resource blocks.

**Path: `/Repos/Shared/<repo-name>`, explicit, not the provider's computed default.**
The default (unset `path`) resolves to a personal folder under the deploying
identity's own space — exactly what caused the first attempt's problem. Setting it
explicitly to the top-level shared path is the actual fix, not incidental.

**Terraform-managed, not CLI-created.**
Same governance-ownership reasoning this repo has applied to everything else: code
first, so the *decision* to have these Git Folders — and their configuration — is
visible in git history, not a one-off action lost to a terminal scrollback.

## Risks / Trade-offs

- [`demo-databricks-iac` referencing itself as a workspace Git Folder] →
  Mitigation: explicitly considered, not just assumed safe. Git Folders is a
  passive browse/sync mechanism — creating one doesn't execute anything from the
  cloned content. Confirmed via the earlier CLI attempt (no issue), redone the
  same way via Terraform.
- [Git Folders drift from `main` over time (no auto-pull)] → Mitigation: accepted;
  this is a browse/dev-convenience feature, not a deployment mechanism — nothing
  in either bundle or Terraform pipeline reads from the Git Folder path.

## Migration Plan

Net-new. Apply, verify both repos appear at the correct path and branch. Rollback:
destroy both `databricks_repo` resources — pure removal, nothing else references
them.
