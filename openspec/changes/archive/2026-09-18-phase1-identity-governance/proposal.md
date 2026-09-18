## Why

Phase 2's CI/CD workflow (`demo-databricks-mdp`'s `phase2-dab-cicd` change, task 2) needs a
Databricks identity to run `bundle deploy` from GitHub Actions. Manually testing service
principal creation showed a newly created SP is added to every existing group by
default — with no functional-group structure in place, that currently means every
built-in group. Before Phase 3+ adds more automation identities that would inherit the
same undifferentiated default, this establishes a minimal functional-group model and
provisions the CI/CD service principal as code rather than clicking it into existence.

## What Changes

- Three Databricks groups: `FG Platform Engineering`, `FG Data Engineering`,
  `FG Data Ops` — the functional-access model going forward; only `FG Data Ops` gets
  members in this change
- One service principal (`svc-cicd-github`): the CI/CD identity GitHub Actions uses to
  run `databricks bundle deploy` against `demo-databricks-mdp`'s `dev`/`tst`/`prd`
  targets
- An OAuth client secret for that service principal (Terraform-managed)
- Both the CI/CD service principal and the human account that manages it
  (`handsonessential@gmail.com`) added to `FG Data Ops`
- No admin grant — considered and explicitly rejected (see design.md); entitlements
  determined empirically against a real `bundle deploy` instead
- All provisioned via Terraform in this repo, authenticated with the existing PAT —
  Terraform's own auth method to Databricks is unchanged by this proposal

## Capabilities

### New Capabilities
- `identity-governance`: functional groups and the CI/CD service principal

### Modified Capabilities
(none)

## Impact

- Adds `databricks_group` (x3), `databricks_service_principal`,
  `databricks_service_principal_secret`, and two group-membership resources (the SP
  and `handsonessential@gmail.com`, both into `FG Data Ops`) to Terraform state
- Produces sensitive outputs (`cicd_client_id`, `cicd_client_secret`) that Phase 2's
  task 2.3 stores as GitHub Actions repository secrets — not stored anywhere else
- `FG Platform Engineering` and `FG Data Engineering` are created but empty — reserved
  for when Phase 3+ introduces real automation/human identities for those functions
- Entitlements and Unity Catalog grants for the CI/CD SP are not fully specified
  upfront — resolved empirically in tasks.md against a real `bundle deploy` attempt
- Does not change how Terraform itself authenticates to Databricks (still the PAT in
  `var.databricks_token`) — that swap is explicitly out of scope here
