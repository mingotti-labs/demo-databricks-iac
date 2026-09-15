terraform {
  required_version = ">= 1.16"

  cloud {
    organization = "hands-on-essential-mingotti"
    workspaces {
      name = "demo-databricks-iac"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.17"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

provider "neon" {
  api_key = var.neon_api_key
}
