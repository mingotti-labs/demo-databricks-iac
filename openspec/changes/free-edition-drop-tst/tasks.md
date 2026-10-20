## 1. Change
- [ ] 1.1 In `deployment/free_workspace/variables.tf`, drop `tst` from the `environments` default; update the variable description and `dev.tfvars.example` comment (`hoe-mdp-dev/prd`, `mdp_dev/prd`)
- [ ] 1.2 Update CLAUDE.md, NAMING.md and README.md mentions of `tst`/three environments for the free workspace
- [ ] 1.3 `terraform fmt` and `terraform validate`

## 2. Preview (no destruction yet)
- [ ] 2.1 Local `terraform plan` with `environment=dev` and the full `uc_external_ids`; confirm it destroys only `tst` resources and changes nothing for `dev`/`prd`
- [ ] 2.2 If the plan lists anything else, or the HCP workspace overrides `environments`, stop and report

## 3. Preparation (each step needs explicit approval)
- [ ] 3.1 Drop the 30 `mdp_tst` schemas with `CASCADE`
- [ ] 3.2 Empty `hoe-mdp-tst` (objects, versions, delete markers)

## 4. Apply and verify
- [ ] 4.1 Merge the PR, then run the approved local `terraform apply` from the reviewed plan
- [ ] 4.2 Confirm `mdp_tst` no longer exists and re-count tables (expect about 344 including `dbacademy`)
