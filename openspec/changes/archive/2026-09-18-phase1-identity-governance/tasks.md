## 1. Groups

- [x] 1.1 Add `databricks_group` resources for `FG Platform Engineering`,
      `FG Data Engineering`, `FG Data Ops` — `terraform plan` showed exactly 3 groups
      (part of 7 to add total); confirmed live via `databricks groups list --profile
      DEFAULT`: all three present alongside the built-in `users`/`admins`
- [x] 1.2 Confirm no members are added to `FG Platform Engineering` or
      `FG Data Engineering` in this change — confirmed via `databricks groups get`
      on both IDs after apply: neither has a `members` key
- [x] 1.3 Document the `FG <Name>` group naming convention in this repo's CLAUDE.md
      (a short "Identity & groups" section) — added, names all three groups, their
      purpose, and the "Terraform-managed, not UI" + "no admin without evidence" rules

## 2. CI/CD service principal

- [x] 2.1 Add a `databricks_service_principal` resource (`svc-cicd-github`) for the
      CI/CD deploy identity — created with all entitlement flags `false`
      (`allow_cluster_create`, `databricks_sql_access`, `workspace_access`,
      `workspace_consume`)
- [x] 2.2 Add a `databricks_service_principal_secret` resource generating its OAuth
      client secret — created; `cicd_client_id` = `74cc0004-a114-4e3d-aac2-d714aadb6910`,
      secret exposed only as a sensitive Terraform output
- [x] 2.3 Add the CI/CD SP and `handsonessential@gmail.com` as members of
      `FG Data Ops` — confirmed via `databricks groups get` on `FG Data Ops`'s ID:
      both listed as members, nothing else
- [x] 2.4 Confirm no admin grant: the SP is not added to the built-in `admins` group,
      and `FG Data Ops` is not nested under it — confirmed via `databricks groups get`
      on the `admins` group ID: `svc-cicd-github` and `FG Data Ops` absent
- [x] 2.5 (Found during 2.4's verification, not originally planned) `admins` already
      had an untracked, pre-existing service principal named "SP Github Actions"
      (application_id `fb045b21-...`) as a member — leftover from the manual SP
      creation test mentioned in the proposal discussion, which auto-joined every
      group including `admins`. Not managed by Terraform, not referenced anywhere.
      User confirmed deletion (2026-09-18); deleted via
      `databricks service-principals delete 76702952934625 --profile DEFAULT` — verified
      `admins` now lists only `handsonessential@gmail.com`

## 3. Verify against a real deploy

- [x] 3.1 Using the SP's OAuth client ID/secret, run
      `databricks bundle deploy --target dev` against `demo-databricks-mdp`'s current
      (empty) bundle — failed first attempt with a specific 403: "disabled for users
      without the databricks-sql-access or workspace-access or workspace-consume
      entitlements"
- [x] 3.2 Granted exactly the narrowest of the three named entitlements
      (`workspace_access = true`) directly on the `svc-cicd-github` resource — not on
      `FG Data Ops` (see chat: group-level entitlements would silently apply to every
      future member of that group, undermining the per-identity evidence-based
      approach). Retried: `bundle deploy --target dev` succeeded — 42 files uploaded,
      0 resources (bundle has none defined yet)
- [x] 3.3 Repeated for `--target tst` and `--target prd` — both succeeded identically
      (42 files uploaded each, to `/Workspace/Shared/.bundle/demo-databricks-mdp/{tst,prd}/files`)
- [x] 3.4 (Found during Phase 2 follow-up, not originally planned) A real job
      (`resources/jobs/hello_world.job.yml`, added in `demo-databricks-mdp`) deployed
      fine but *running* it failed with `PERMISSION_DENIED: User does not have USE
      CATALOG on Catalog 'mdp_dev'` — deploy-time entitlement isn't the same as
      run-time Unity Catalog access. Added `databricks_grants` on each of the three
      catalogs granting `svc-cicd-github` (by `application_id`, i.e. the OAuth
      client_id) `USE_CATALOG` only — root-composed in `deployment/free_workspace/
      main.tf`, not inside either module, since it wires two modules' outputs
      together. Verified: `bundle run hello_world` succeeds (`TERMINATED SUCCESS`)
      against `dev`, `tst`, and `prd`

## 4. Output handoff

- [x] 4.1 Confirm `outputs.tf` exposes the CI/CD SP's `cicd_client_id` (plain) and
      `cicd_client_secret` (marked `sensitive = true`) — confirmed working: both were
      used directly (via `terraform output -raw`) to authenticate the real deploys in
      3.1-3.3
- [x] 4.2 Hand off to `demo-databricks-mdp`'s `phase2-dab-cicd` task 2.3: store
      `client_id`/`client_secret` (renamed `DATABRICKS_CLIENT_ID`/
      `DATABRICKS_CLIENT_SECRET`) plus `DATABRICKS_HOST` as GitHub Actions repository
      secrets — done via `gh secret set` (value piped through command substitution,
      never printed); `gh secret list --repo mingotti-labs/demo-databricks-mdp`
      confirms all three present (masked), and this repo's Terraform state is the
      only other place they're recorded
