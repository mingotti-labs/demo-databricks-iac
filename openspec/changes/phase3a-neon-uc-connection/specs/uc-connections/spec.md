## ADDED Requirements

### Requirement: Neon dev UC Connection
A Unity Catalog `CONNECTION` named `neon_dev` SHALL exist, type `POSTGRESQL`,
authenticated against the Neon `dev` branch's own compute endpoint (not `main`'s),
with `sslmode` explicitly set to `require`.

#### Scenario: Connection created
- **WHEN** the uc-connections resources are applied
- **THEN** a UC Connection named `neon_dev` exists with `connection_type =
  POSTGRESQL`, and its `host` option matches the Neon `dev` branch's compute
  endpoint

### Requirement: Connectivity verified, not assumed
The connection SHALL be confirmed reachable via a live query against it, not
inferred from `terraform apply` succeeding alone.

#### Scenario: Live connectivity check
- **WHEN** a query against the `neon_dev` connection (e.g. `SHOW SCHEMAS IN
  CONNECTION neon_dev`) is run after apply
- **THEN** it succeeds and lists at least the `public` schema, proving real
  network reachability and authentication to the Neon `dev` branch
