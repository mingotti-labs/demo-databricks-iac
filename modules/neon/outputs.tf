output "main_host" {
  value = neon_project.this.database_host
}

output "main_database_name" {
  value = neon_project.this.database_name
}

output "main_role_name" {
  value = neon_project.this.database_user
}

output "main_password" {
  value     = neon_project.this.database_password
  sensitive = true
}

output "dev_host" {
  value = neon_endpoint.dev.host
}

output "dev_database_name" {
  value = neon_project.this.database_name
}

output "dev_role_name" {
  value = var.role_name
}

output "dev_password" {
  value     = data.neon_branch_role_password.dev.password
  sensitive = true
}
