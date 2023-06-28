output "keycloak_config_for_firezone" {
  value = {
    client_id               = keycloak_openid_client.firezone.client_id
    client_secret           = keycloak_openid_client.firezone.client_secret
    discovery_document_uri  = "https://${module.settings.keycloak.subdomain}.${module.settings.domain}:${module.settings.keycloak.port}/realms/${keycloak_realm.realm.realm}/.well-known/openid-configuration"
  }
  sensitive = true
}

output "test_user_credentials" {
  value = {
    test_user_name = module.settings.keycloak.test_user.name
    test_user_password = random_string.kc_test_user_password.result  
  }
  sensitive = true
}
