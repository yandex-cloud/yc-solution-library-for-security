# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.13"
    }
    # null = {
    #   source = "hashicorp/null"
    #   version = "~> 3.1.0"
    # }
  }
}

# provider "yandex" {
#   zone      = "ru-central1-a"
# }
