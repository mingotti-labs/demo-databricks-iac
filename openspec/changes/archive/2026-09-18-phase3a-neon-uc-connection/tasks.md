## 1. Module

- [x] 1.1 Create `modules/databricks-uc-connection-postgres/` with `name`, `host`,
      `port` (default `"5432"`), `user`, `password` (sensitive) inputs and a
      `databricks_connection` resource (`connection_type = "POSTGRESQL"`) — first
      apply attempt included `sslmode = "require"` and failed with a specific,
      exact error: `does not support the following option(s): sslmode. Supported
      options: userProvidedServerCertificate,host,port,trustServerCertificate,
      user,password`. Removed it — Neon negotiates SSL on its own regardless, and
      this option genuinely isn't supported by this connection type (not a guess,
      the API said so directly)
- [x] 1.2 Output `connection_name`

## 2. Root composition

- [x] 2.1 Add `module "neon_dev_connection"` wired to `module.neon.dev_host`/
      `dev_role_name`/`dev_password`, `name = "neon_dev"` — `terraform plan` showed
      exactly 1 resource to create both times (before and after the sslmode fix)

## 3. Apply and verify

- [x] 3.1 Apply — succeeded on the second attempt (after removing `sslmode`): 1
      added, 0 changed, 0 destroyed
- [x] 3.2 Verify real connectivity with a live query — `SHOW SCHEMAS IN CONNECTION
      neon_dev` is not valid syntax either (`PARSE_SYNTAX_ERROR`, confirmed via a
      real query attempt). Used the actual documented mechanism instead: a
      temporary foreign catalog on top of the connection
      (`CREATE FOREIGN CATALOG IF NOT EXISTS neon_dev_test_catalog USING
      CONNECTION neon_dev OPTIONS (database 'app')`), then
      `SHOW SCHEMAS IN neon_dev_test_catalog` — returned `information_schema`,
      `pg_catalog`, `public`: definitive proof of live connectivity and
      authentication to Neon's `dev` branch. The temporary catalog was then
      dropped (`DROP CATALOG neon_dev_test_catalog`) and confirmed gone
      (`databricks catalogs get` → "does not exist") — it's a verification
      artifact only, not part of the design (Lakeflow Connect uses the Connection
      directly, no foreign catalog needed)
- [x] 3.3 Confirm `databricks connections get neon_dev` shows no error state —
      confirmed: `provisioning_info.state = "ACTIVE"`, host matches the `dev`
      branch's endpoint

## 4. Documentation

- [x] 4.1 Add a note to this repo's CLAUDE.md: the `neon_dev` UC Connection exists,
      points at Neon's `dev` branch, and is consumed by
      `phase3a-lakeflow-connect-neon` in `demo-databricks-mdp` (cross-repo reference,
      per CONTRIBUTING.md's new convention)
