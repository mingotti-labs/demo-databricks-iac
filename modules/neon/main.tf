terraform {
  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18"
    }
  }
}

resource "neon_project" "this" {
  name                      = var.project_name
  region_id                 = var.region_id
  org_id                    = var.org_id
  history_retention_seconds = var.history_retention_seconds
  # main is the stable/production-equivalent data line (git convention: main IS
  # prod, no rename needed). NOT protected: Neon's free tier allows zero protected
  # branches (BRANCHES_PROTECTED_LIMIT_EXCEEDED on apply, confirmed empirically) --
  # accepted limitation, see phase1-neon-branching's design.md.

  branch {
    database_name = var.database_name
    role_name     = var.role_name
  }
}

# dev: forked from main, where active development and downstream ingestion work
# happens. Copy-on-write, so it inherits main's database/role at fork time --
# no separate neon_database/neon_role resources needed.
resource "neon_branch" "dev" {
  project_id = neon_project.this.id
  name       = "dev"
  parent_id  = neon_project.this.default_branch_id
}

resource "neon_endpoint" "dev" {
  project_id = neon_project.this.id
  branch_id  = neon_branch.dev.id
}

data "neon_branch_role_password" "dev" {
  project_id = neon_project.this.id
  branch_id  = neon_branch.dev.id
  role_name  = var.role_name
}
