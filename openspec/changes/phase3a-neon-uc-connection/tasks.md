## 1. Module

- [ ] 1.1 Create `modules/databricks-uc-connection-postgres/` with `name`, `host`,
      `port` (default `"5432"`), `user`, `password` (sensitive) inputs and a
      `databricks_connection` resource (`connection_type = "POSTGRESQL"`, options
      including `sslmode = "require"`) — verify `terraform validate`
- [ ] 1.2 Output `connection_name` — verify referenced correctly from the root

## 2. Root composition

- [ ] 2.1 Add `module "neon_dev_connection"` wired to `module.neon.dev_host`/
      `dev_role_name`/`dev_password`, `name = "neon_dev"` — verify `terraform plan`
      shows exactly 1 resource to create

## 3. Apply and verify

- [ ] 3.1 Apply — verify `terraform apply` completes with 1 added, 0 changed,
      0 destroyed
- [ ] 3.2 Verify real connectivity with a live query (not assumed from apply
      succeeding) — run `SHOW SCHEMAS IN CONNECTION neon_dev` (or the working
      equivalent if that syntax doesn't apply to this connection type) via a SQL
      warehouse query; record the exact command run and its real output in this
      task. Expected: the `public` schema is listed (Neon's default schema — the
      seed data doesn't need to exist yet for this to succeed, an empty schema still
      proves auth + network path)
- [ ] 3.3 Confirm `databricks connections get neon_dev` shows no error state

## 4. Documentation

- [ ] 4.1 Add a note to this repo's CLAUDE.md: the `neon_dev` UC Connection exists,
      points at Neon's `dev` branch, and is consumed by
      `phase3a-lakeflow-connect-neon` in `demo-databricks-mdp` (cross-repo reference,
      per CONTRIBUTING.md's new convention)
