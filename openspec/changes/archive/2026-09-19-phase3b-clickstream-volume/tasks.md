## 1. Schema

- [x] 1.1 Add `bronze_clickstream` to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf` — verify with `terraform plan`
      showing exactly 3 additional schema resources to add (one per environment
      catalog), no changes to existing schemas — confirmed, but only once
      `-var="environment=dev"` and the current `uc_external_ids` were passed
      explicitly; without them, `terraform plan` showed 3 unrelated changes and
      3 replacements against the AWS IAM trust policies (see task 3.1's note)

## 2. Volume module

- [x] 2.1 Create `modules/databricks-uc-volume/` with `catalog_name`,
      `schema_name`, `volume_name` inputs and a `databricks_volume` resource
      (`volume_type = "MANAGED"`, no `storage_location` set) — `terraform
      validate` passed
- [x] 2.2 Output `volume_path` — resolves to
      `/Volumes/<catalog_name>/<schema_name>/<volume_name>`

## 3. Root composition

- [x] 3.1 Add `module "clickstream_volume"` in `deployment/free_workspace/main.tf`
      with `for_each = var.environments`, `catalog_name =
      module.unity_catalog[each.key].catalog_name`, `schema_name =
      "bronze_clickstream"`, `volume_name = "s3_clickstream_raw"`, and
      `depends_on = [module.unity_catalog]` — `terraform plan` initially showed
      6 to add, 3 to change, 3 to destroy: the "change"/"destroy" were
      pre-existing, unrelated to this change — omitting `-var="uc_external_ids=
      ..."` made Terraform plan to strip the `sts:ExternalId` condition from
      each environment's IAM trust policy (reverting to the variable's empty
      default) and replace the `time_sleep.iam_propagation` resource that
      depends on it. Re-ran with the current `uc_external_ids` values (from
      `terraform output -json uc_external_ids`) explicitly passed — clean plan,
      exactly 6 to add, 0 to change, 0 to destroy

## 4. Apply and verify

- [x] 4.1 Apply — 6 added, 0 changed, 0 destroyed, confirmed in `terraform
      apply` output
- [x] 4.2 Verified each volume is real and empty:
      `databricks volumes read mdp_<env>.bronze_clickstream.s3_clickstream_raw`
      for `dev`/`tst`/`prd` — all three `volume_type = MANAGED`, each backed by
      its own environment's bucket (`storage_location` under
      `s3://hoe-mdp-<env>/__unitystorage/...`); `databricks fs ls
      dbfs:/Volumes/mdp_dev/bronze_clickstream/s3_clickstream_raw` returned no
      files, confirming empty
- [x] 4.3 CI/CD SP read/write access to these volumes is deliberately left
      unverified here (see design.md's Risks) — flagged for
      `phase3b-clickstream-autoloader` to surface empirically, not pre-solved

## 5. Documentation

- [x] 5.1 Added a note to this repo's CLAUDE.md ("UC Volumes" section): the
      `bronze_clickstream` schema and `s3_clickstream_raw` volume exist per
      environment, and are consumed by `phase3b-clickstream-autoloader` in
      `demo-databricks-mdp`. Also added a "Running Terraform locally" section
      documenting the `environment`/`uc_external_ids` CLI-var requirement
      discovered while implementing task 3.1, since it's a real operational
      trap unrelated to this change's own scope but surfaced by it
