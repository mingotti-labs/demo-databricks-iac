## Context

See proposal.md. The story's sources and layers are fixed by the approved
design in `demo-databricks-planning`. This change only provisions the
containers and credentials; it creates no tables.

## Goals / Non-Goals

**Goals:**
- Every schema, secret and volume the story's version one needs, in one apply.
- Same mechanisms as existing sources: `local.schemas`,
  `local.cicd_writable_schemas`, a scope per source in
  `modules/databricks-secret-scopes`, `databricks_secret_acl` for runtime
  reads, `modules/databricks-uc-volume` plus an explicit volume grant.

**Non-Goals:**
- `silver_normalised_<s>` schemas: each mdp change decides whether its source
  needs Silver Normalised; the schema then comes in a small iac change.
- Gold schemas: `gold_analytics_gateway` already exists.
- Secrets for the SEC (its `User-Agent` contact is not a secret; it is an mdp
  bundle variable), Yahoo, Wikipedia or RBA (no keys).

## Decisions

**Three schemas per source, including `reference` and `portfolio`.**
Every source in the story follows the platform shape (`_raw`, bronze publish,
Silver Landing), including the reference CSVs and the purchases CSV, so they
get the same three schemas. Empty schemas cost nothing against the 500-table
limit; a schema the probes make unnecessary (e.g. Wikipedia's, if FMP covers
everything) is dropped later while still empty.

**`silver_investments` is the first Silver Domain schema.**
The `unity-catalog` spec forbade Silver Domain schemas until a domain was
defined; the story defines the first one (conformed companies, dividends,
prices, fundamentals, rates). The requirement now allows Silver Domain
schemas that a story defines.

**Scopes `fmp` and `fred`, key `api_key` each.**
Same shape as `airroi`: one scope per source, one key, value from a sensitive
root variable threaded through the module. Both are read at runtime by
pipeline code, so both get `READ` for the CI/CD service principal from the
start (the airroi and neon gaps were found only after failures).

**Volume `s3_raw`, human account can write.**
New naming rule `<service>_raw` (decided by the user): the volume lives in
`bronze_<source>`, so its full name `catalog.bronze_<source>.s3_raw` already
names the source, and volume names only need to be unique within a schema,
so two sources' `s3_raw` volumes never clash. Clickstream's
`s3_clickstream_raw` keeps its name as a recorded exception: renaming it
could recreate the volume and lose its files, which is not worth checking
for a name. Unlike
clickstream (written by a generator job), this volume is written by a person
uploading their purchases CSV, so the human account gets `READ_VOLUME` and
`WRITE_VOLUME` alongside the CI/CD service principal.

## Risks / Trade-offs

- [The user has no FRED key yet] → Mitigation: the plan fails on a missing
  variable; the user gets a free key from FRED before the plan.
- [Large plan, 110 additions] → Mitigation: all additive, reviewed in full
  before apply; counts per type listed in proposal.md to check against.

## Migration Plan

Additive only. Apply, then check: `databricks schemas list mdp_dev` and
`mdp_prd` show the 25 new schemas; `databricks secrets list-scopes` shows `fmp`
and `fred`, each holding `api_key`; `databricks secrets list-acls fmp|fred`
lists the CI/CD service principal with `READ`; `databricks volumes list
mdp_dev bronze_portfolio` shows `s3_raw`; `databricks grants get
schema mdp_dev.silver_investments` shows the CI/CD grants. Rollback: destroy
the new resources; nothing consumes them yet.
