## 1. Verify the rename's blast radius

- [x] 1.1 Change the root `neon` module call's `project_name` to `"mdp"` and run
      `terraform plan` (no apply) — confirmed in-place (`~ name = "mdp-dev" ->
      "mdp"`), not forced replacement

## 2. Module changes

- [x] 2.1 Add `neon_branch.dev` (`parent_id = neon_project.this.default_branch_id`,
      `name = "dev"`) to `modules/neon/main.tf`
- [x] 2.2 Add `neon_endpoint.dev` (`branch_id = neon_branch.dev.id`)
- [x] 2.3 Add `data.neon_branch_role_password.dev` (`branch_id = neon_branch.dev.id`,
      `role_name = var.role_name`)
- [x] 2.4 Set `default_branch_protected = true` on `neon_project.this` — **reverted**.
      First apply attempt failed: `BRANCHES_PROTECTED_LIMIT_EXCEEDED` — Neon's free
      tier allows zero protected branches, confirmed via the actual API error, not
      assumed from docs (the general "10 branches/project" limit checked earlier is a
      different quota from protected-branch count). Also discovered the provider had
      recorded `default_branch_protected = true` in local state despite the API call
      failing — `terraform plan`'s refresh step showed "Drift detected (update)" and
      corrected it back to the real value (`false`) once the setting was removed from
      config. `main` is unprotected; accepted, see design.md.
- [x] 2.5 Restructure `modules/neon/outputs.tf`: renamed existing outputs to
      `main_host`/`main_database_name`/`main_role_name`/`main_password`, added
      `dev_host`/`dev_database_name`/`dev_role_name`/`dev_password`

## 3. Root wiring

- [x] 3.1 Update `deployment/free_workspace/main.tf`'s `neon` module call:
      `project_name = "mdp"`
- [x] 3.2 Update `secret_scopes` module call to source from `module.neon.dev_*` —
      `terraform plan` showed exactly the expected diff: `neon_host`/`neon_password`
      secrets replaced (value changed — `databricks_secret` forces replacement on
      value change, normal provider behavior), `neon_database_name`/`neon_role_name`
      untouched (identical values, inherited via the fork)

## 4. Apply and verify

- [x] 4.1 Review the full plan, apply — first attempt partially failed on the
      protected-branch limit (see 2.4); second attempt (after removing that setting)
      applied cleanly: 4 added, 0 changed, 0 destroyed. Follow-up `terraform plan`
      confirms no drift ("No changes")
- [x] 4.2 Confirm branch topology — confirmed via Terraform state: `main`
      (`ep-solitary-dawn-a7sng28z...`) and `dev` (`ep-winter-wildflower-a7ivglrn...`),
      two genuinely distinct compute endpoints
- [x] 4.3 Confirm the `neon-postgres` secret scope resolves to `dev`'s connection —
      verified for real via a one-time Databricks job (`databricks jobs submit`) that
      compared the secret's host value against both known endpoints internally and
      returned only a safe verdict (raw secret value came back `[REDACTED]` when
      returned directly — Databricks auto-redacts notebook output matching a known
      secret value, so the comparison had to happen inside the notebook). Result:
      `MATCHES_DEV`. Temporary notebook and job deleted afterward.

## 5. Documentation

- [x] 5.1 Update this repo's CLAUDE.md to note the project is now `mdp` (not
      `mdp-dev`), has two branches (`main` = stable/prod line per git convention,
      unprotected due to the free-tier limit; `dev` = active development, what
      `neon-postgres` actually points at), and the accepted Atlas naming
      inconsistency
