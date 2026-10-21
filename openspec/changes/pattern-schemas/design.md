## Context

The per-environment catalog module (`databricks-unity-catalog`) owns a fixed
schema map applied to every catalog. Pattern output must exist in `dev` only,
so it cannot live in that map without conditional logic. The root already has
the shape needed: `module.unity_catalog["dev"]` exposes `catalog_name`.

## Decisions

- **A separate module, instantiated once.** Same style as
  `databricks-uc-volume` (a small module, composition at the root).
  `for_each` over `environments` would create the schemas in every catalog, and
  a conditional inside the catalog module would add the edition-style branching
  this project avoids.
- **Reference `module.unity_catalog["dev"]` directly.** `dev` is a fixed key in
  both roots. If `dev` were ever removed, the plan fails loudly instead of
  silently dropping the schemas.
- **Two schemas now, more on demand.** `pattern_bronze` (Auto Loader variants)
  and `pattern_bronze_publish` (the SQL twins, later). Other layers are one map
  entry each, added when a pattern needs one.
- **No grants yet.** The patterns bundle is deployed by hand as the human
  operator, who owns what Terraform creates. The CI/CD service principal gets
  the same three schema privileges as other schemas when CI deploys that bundle;
  adding them early would grant access nothing uses.
- **Mirror to `single_workspace`** so the reference copy matches; it is only
  `init -backend=false` plus `validate` there.
- **No `force_destroy`**, consistent with the earlier decision.

## Risks

- **Local plan scope.** Terraform runs locally against HCP: the plan must show
  exactly 2 to add and nothing else. Anything else (especially an
  `uc_external_ids` change) is a stop.
- **`uc_external_ids`** must be passed in full for `dev` and `prd`, or the plan
  strips the `sts:ExternalId` condition from the trust policies (CLAUDE.md).
- **Ordering with the mdp follow-up.** The pattern pipelines must not point at
  `pattern_bronze` until the schemas exist, hence apply first.
