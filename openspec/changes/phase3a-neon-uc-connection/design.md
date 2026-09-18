## Context

See proposal.md - Why. This is the first UC Connection this project creates. The
`databricks-lakeflow-connect` skill's Key Concepts are explicit that the Connection
is the credential anchor a pipeline points at by name — get this wrong or leave it
unverified, and the failure surfaces later, inside `demo-databricks-mdp`'s pipeline,
farther from the actual cause. Per direct instruction, connectivity gets verified
here, before that pipeline is built on top of it.

## Goals / Non-Goals

**Goals:**
- A working, *verified* UC Connection to Neon's `dev` branch before `mdp`'s
  ingestion pipeline depends on it
- Reusable module shape, not a one-off hardcoded resource, in case a second Postgres
  connection is ever needed

**Non-Goals:**
- A connection to `main` — no consumer yet, same "reserved, not built" reasoning as
  other deliberately-deferred pieces in this project. Add it when something needs it.
- Anything Lakeflow-Connect-pipeline-specific (tables, cursor columns, schedules) —
  that's `mdp`'s job, this change only creates the credential anchor.

## Decisions

**New module, not an inline root resource.**
Every other piece of this repo's infrastructure — even single-instance things like
the identity-governance groups — lives in a module, composed at the root. A UC
Connection is no different in kind, and a generic (not Neon-specific) module means a
future second Postgres connection doesn't require touching this one's internals.

**`sslmode = "require"` set explicitly.**
Neon's own documented connection strings always include this. The Databricks
connection-options docs list `sslmode` as optional with no stated default. Rather
than trust an unstated default to happen to be safe, it's set explicitly — the same
"verify, don't assume" instinct that shaped the rest of this project's infra work.

**Verified via a live query, not `terraform apply` succeeding alone.**
`apply` succeeding proves the Databricks API accepted the connection's
configuration; it doesn't prove Databricks can actually reach and authenticate to
Neon over the network. Those are different claims. tasks.md includes an explicit
live-query verification step (`SHOW SCHEMAS IN CONNECTION neon_dev` or equivalent)
run and its real output recorded, specifically so a connectivity problem is caught
here — not discovered later when `mdp`'s pipeline fails for a reason that traces
back to this object.

## Risks / Trade-offs

- [The connection references `dev`'s host/credentials at apply time; if `dev` is
  ever destroyed and recreated, this connection needs a re-apply to pick up the new
  values] → Mitigation: it's a Terraform output reference
  (`module.neon.dev_host` etc.), not a hardcoded value, so a `dev` recreation flows
  through automatically on the next `terraform apply` — not a hidden manual step.

## Migration Plan

Net-new. Apply, then verify live connectivity via SQL before considering this done
(see tasks.md). Rollback: destroy the connection — nothing consumes it until
`phase3a-lakeflow-connect-neon` is built, so there's no cascading impact if this
needs to be redone.
