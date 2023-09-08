output "firezone_url" {
  value = "https://${module.settings.firezone.subdomain}.${module.settings.domain}"
}

output "firezone_admin_credentials" {
  value = {
    admin_email = module.settings.firezone.admin_email
    admin_password = module.firezone.output.admin_password
  }
  sensitive = true
}

output "keycloak_url" {
  value = "https://${module.settings.keycloak.subdomain}.${module.settings.domain}:${module.settings.keycloak.port}/admin"
}

output "keycloak_admin_credentials" {
  value = {
    admin_username = module.settings.keycloak.admin_user
    admin_password = module.keycloak-deploy.kc_admin_password
  }
  sensitive = true
}