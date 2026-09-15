output "host" {
  value = neon_project.this.database_host
}

output "database_name" {
  value = neon_project.this.database_name
}

output "role_name" {
  value = neon_project.this.database_user
}

output "password" {
  value     = neon_project.this.database_password
  sensitive = true
}
