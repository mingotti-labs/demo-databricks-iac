# Contributing

Workflow conventions for this repo — followed the same way whether a change is written
by a person or an AI coding agent.

## Branching

Create branches as `feature/<short-kebab-case-description>` (e.g.
`feature/phase1-deployment-restructure`).

## Commits

Conventional-style prefixes — `feat:`, `fix:`, `chore:`, `docs:`, `refactor:` — one-line
summary in the present tense, explaining why over what where the diff itself doesn't
already make that obvious.

## Pull requests

Every change lands via PR. `main` is squash-merged only — branch protection requires
linear history, so no merge commits, no force push, no deletion of `main`.

## Cross-repo dependencies

OpenSpec has no cross-repo linking — each repo's `openspec/` only sees its own
changes. When a change in this repo depends on, or is depended on by, a change in
`demo-databricks-mdp` (or vice versa), say so explicitly in `proposal.md` under a
`## Cross-repo dependencies` heading: the other change's ID, its repo, and which
direction the dependency runs (e.g. "Provides for `phase3a-lakeflow-connect-neon` in
`demo-databricks-mdp` — that change's ingestion pipeline references the
`neon_dev` UC Connection this change creates"). Plain text, not tooling — grep-able
is the goal.

## Comments

Default to no comments — clear naming should carry most of the load. Add one only
where the *why* isn't visible from the code itself: a behavior enforced somewhere
else entirely, a non-obvious constraint, or a deliberate trade-off a future reader
could otherwise "fix" by accident. Never comment what the code already says plainly.
