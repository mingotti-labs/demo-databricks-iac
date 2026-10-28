## Why

The dividend portfolio story moves raw ingestion to append-only, replayable
files (decided by the user, 2026-10-28): a fetch task writes dated files into a
volume and Auto Loader appends them into the raw tables. SEC (next), Yahoo
(after it) and Wikipedia (converted later) need a volume for that. The same
change removes what the probes made unnecessary (decided by the user,
2026-10-25): FMP was dropped and the `reference` source was folded into
`portfolio`.

## What Changes

- **Add** a managed volume `s3_raw` in `bronze_sec`, `bronze_yahoo` and
  `bronze_wikipedia`, per environment, with `READ_VOLUME`/`WRITE_VOLUME` for the
  CI/CD service principal and the human account (same shape as
  `bronze_portfolio.s3_raw`).
- **Remove** (all empty, never used):
  - the `fmp` secret scope, its `api_key` secret, the CI/CD `READ` ACL and the
    root variable `fmp_api_key`;
  - the schemas `bronze_fmp`, `bronze_fmp_publish`, `silver_landing_fmp`,
    `bronze_reference`, `bronze_reference_publish`,
    `silver_landing_reference`, and their CI/CD grants.
- Both deployments (`free_workspace`, `single_workspace`), kept identical.

## Capabilities

### New Capabilities

### Modified Capabilities
- `uc-volumes`: three new source volumes.
- `unity-catalog`: the six `fmp` and `reference` schemas are no longer present.
- `secret-scopes`: the `fmp` scope is removed; the runtime-read list drops it.

## Impact

- Terraform, expected per the plan (two environments in Free Edition):
  12 to add (6 volumes, 6 volume grants); 27 to destroy (12 schemas, 12 schema
  grants, the `fmp` scope, its secret and its ACL). Confirmed by
  `terraform plan` before apply.
- HCP Terraform: the workspace variable `fmp_api_key` becomes unused; the user
  deletes it after the apply.
- No table count change (the removed schemas are empty).

## Cross-repo dependencies

Depended on by `sec-company-facts` in `demo-databricks-mdp`: its fetch task
writes to `bronze_sec.s3_raw`, so this change must be applied first. Yahoo's
change and the later Wikipedia conversion in mdp use the other two volumes.

## Model

Sonnet: repeats the existing volume and grant shape and removes resources
already listed; the plan walk-through carries the risk.
