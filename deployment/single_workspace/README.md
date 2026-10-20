# single_workspace

Reference copy of `../free_workspace/` with all three environments (`dev`, `tst`,
`prd`). **Never applied.** It has no `cloud` block on purpose: it must not share
the HCP Terraform state of `free_workspace`. Configure its own backend before
the first `init`.

The Free Edition workarounds copied here (workspace-level groups only,
placeholder access groups, no account-level API) are probably wrong for a paid
edition and need review before real use.
