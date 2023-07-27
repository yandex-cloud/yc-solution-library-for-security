terraform {
  required_providers {
    keycloak = {
      # https://github.com/mrparkers/terraform-provider-keycloak/tree/master
      source = "mrparkers/keycloak"
      version = "~> 4.2.0"
    }
  }
}
