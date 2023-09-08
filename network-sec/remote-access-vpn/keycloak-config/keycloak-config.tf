# ================================
# Keycloak configuration resources 
# ================================

# https://github.com/mrparkers/terraform-provider-keycloak/tree/master

provider "keycloak" {
  client_id = "admin-cli"
  username = module.settings.keycloak.admin_user
  password = var.kc_admin_password
  url = "https://${module.settings.keycloak.subdomain}.${module.settings.domain}:${module.settings.keycloak.port}"
}

resource "random_string" "kc_test_user_password" {
  length  = 12
  upper   = true
  lower   = true
  numeric  = true
  special = true
  override_special = "!@%&*()-_=+[]{}<>:?"
}

resource "keycloak_realm" "realm" {
  realm = "firezone"
  enabled = true
  display_name = "Firezone"
  display_name_html = "<b>Firezone</b>"
  ssl_required = "external"
  registration_allowed = false
  registration_email_as_username = false
  remember_me = false
  verify_email = false
  reset_password_allowed = false
  login_with_email_allowed = false

  internationalization {
    supported_locales = [ "en" ]
    default_locale = "en"
  }
}

# Keycloak OpenID Connect client
resource "keycloak_openid_client" "firezone" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "firezone"
  name                = "Keycloak for Firezone"
  enabled             = true
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled = true
  direct_access_grants_enabled = true
  use_refresh_tokens  = true
  pkce_code_challenge_method = "S256"
  valid_redirect_uris = [
    "https://${module.settings.firezone.subdomain}.${module.settings.domain}/auth/oidc/keycloak/callback/"
  ]
  valid_post_logout_redirect_uris = [
    "https://${module.settings.firezone.subdomain}.${module.settings.domain}/"
  ]
}

# Keycloak test user account
resource "keycloak_user" "test_user" {
  realm_id = keycloak_realm.realm.id
  username = module.settings.keycloak.test_user.name
  enabled = true
  email = module.settings.keycloak.test_user.email
  email_verified = true
  attributes = {}
  initial_password {
    value = "${random_string.kc_test_user_password.result}"
    temporary = false
  }
}