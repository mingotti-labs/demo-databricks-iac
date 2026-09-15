output "connection_string" {
  value = mongodbatlas_advanced_cluster.this.connection_strings.standard_srv
}

output "username" {
  value = mongodbatlas_database_user.this.username
}

output "password" {
  value     = random_password.database_user.result
  sensitive = true
}
