terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_connection" "this" {
  name            = var.name
  connection_type = "POSTGRESQL"

  # sslmode is NOT a supported option for this connection type -- confirmed via a
  # real apply rejection ("does not support the following option(s): sslmode",
  # supported: userProvidedServerCertificate, host, port, trustServerCertificate,
  # user, password). Neon negotiates SSL on its own regardless.
  options = {
    host     = var.host
    port     = var.port
    user     = var.user
    password = var.password
  }
}
