# pattern-schemas Specification

## Purpose
TBD - created by archiving change pattern-schemas. Update Purpose after archive.

## Requirements

### Requirement: Pattern schemas exist in dev only
The deployment SHALL create the schemas `pattern_bronze` and
`pattern_bronze_publish` in the `dev` catalog, and no pattern schema in any
other catalog.

#### Scenario: Dev catalog
- **WHEN** the schemas of the `dev` catalog are listed
- **THEN** `pattern_bronze` and `pattern_bronze_publish` are present

#### Scenario: Prd catalog
- **WHEN** the schemas of the `prd` catalog are listed
- **THEN** no schema starts with `pattern_`

### Requirement: Pattern schemas come from their own module
The pattern schemas SHALL be created by a dedicated module instantiated once
against the `dev` catalog, not by the per-environment catalog module, so that
adding an environment never adds pattern schemas.

#### Scenario: Adding an environment
- **WHEN** a key is added to `environments`
- **THEN** the plan creates no pattern schema for it

### Requirement: Pattern schema naming
A pattern schema SHALL be named `pattern_<layer>`, where `<layer>` is a
medallion schema family used by the design-pattern register (`bronze`,
`bronze_publish`, and so on).

#### Scenario: Name of a pattern schema
- **WHEN** a pattern schema is added for a layer
- **THEN** its name is `pattern_` followed by that layer's name
