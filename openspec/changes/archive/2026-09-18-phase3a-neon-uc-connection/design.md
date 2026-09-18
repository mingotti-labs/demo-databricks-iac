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

**No `sslmode` option — reverted after a real apply rejection.**
The intent was `sslmode = "require"`, matching Neon's own documented connection
strings and the general Databricks docs on connection options. The actual API
rejected it: `does not support the following option(s): sslmode. Supported
options: userProvidedServerCertificate,host,port,trustServerCertificate,user,
password` — this connection type's real, current option set is narrower than the
general documentation implied. Removed; Neon negotiates SSL on its own regardless
of what the connection object specifies.

**Verified via a live query through a temporary foreign catalog, not `terraform
apply` succeeding alone — and not the SQL first assumed, either.**
`apply` succeeding proves the Databricks API accepted the connection's
configuration; it doesn't prove Databricks can actually reach and authenticate to
Neon over the network. Those are different claims, and the first syntax tried to
close that gap (`SHOW SCHEMAS IN CONNECTION neon_dev`) turned out not to exist
either (`PARSE_SYNTAX_ERROR`). The real, documented mechanism is a temporary
`CREATE FOREIGN CATALOG ... USING CONNECTION`, browsed with `SHOW SCHEMAS IN
<that catalog>`, then dropped — heavier than hoped, but definitive: it returned
Neon's real schemas (`public`, `pg_catalog`, `information_schema`). See tasks.md
for the exact commands and output.

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
