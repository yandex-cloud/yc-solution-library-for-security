# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2.1"
    }
    # https://registry.tfpla.net/providers/mrparkers/keycloak/latest/docs
    keycloak = {
      source = "mrparkers/keycloak"
      version = "~> 4.1.0"
    }
  }
}
