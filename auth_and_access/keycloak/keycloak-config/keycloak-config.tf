# ================================
# Keycloak configuration resources 
# ================================

# https://registry.tfpla.net/providers/mrparkers/keycloak/latest/docs

provider "keycloak" {
  client_id = "admin-cli"
  username = var.kc_adm_user
  password = var.kc_adm_pass
  url = "https://${var.kc_fqdn}:${var.kc_port}"
}

resource "keycloak_realm" "realm" {
  realm = var.kc_realm_name
  enabled = true
  display_name = var.kc_realm_descr
  display_name_html = "<b>${var.kc_realm_descr}</b>"
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

  security_defenses {
    headers {
      x_frame_options = "DENY"
      content_security_policy = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options = "nosniff"
      x_robots_tag = "none"
      x_xss_protection = "1; mode=block"
      strict_transport_security = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout = false
      max_login_failures = 10
      wait_increment_seconds = 60
      quick_login_check_milli_seconds = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds = 900
      failure_reset_time_seconds = 43200
    }
  }
}

resource "keycloak_saml_client" "client" {
  realm_id  = keycloak_realm.realm.id
  name = "${var.fed_name}-federation"
  enabled = true

  client_id = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.kc_fed.id}"
  base_url = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.kc_fed.id}"
  valid_redirect_uris = [ "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.kc_fed.id}" ]
  idp_initiated_sso_relay_state = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.kc_fed.id}"

  assertion_consumer_redirect_url = "https://console.cloud.yandex.ru"

  sign_documents = true
  sign_assertions = true
  include_authn_statement = true
  name_id_format = "username"
  force_name_id_format = false
  signature_algorithm = "RSA_SHA256"
  signature_key_name = "CERT_SUBJECT"
  full_scope_allowed = true

  client_signature_required = true
  force_post_binding = true
  encrypt_assertions = true

  signing_certificate = file("${abspath(path.module)}/${var.yc_cert}")
  encryption_certificate = file("${abspath(path.module)}/${var.yc_cert}")
}

resource "keycloak_generic_protocol_mapper" "role_list_mapper" {
  realm_id = keycloak_realm.realm.id
  client_id = keycloak_saml_client.client.id
  name = "role list"
  protocol = "saml"
  protocol_mapper = "saml-role-list-mapper"
  config = {
    "attribute.name" = "Role"
    "attribute.nameformat" = "Basic"
    "single" = "true"
  }
}

resource "keycloak_saml_user_property_protocol_mapper" "property_email" {
  realm_id = keycloak_realm.realm.id
  client_id = keycloak_saml_client.client.id
  name = "X500 email"
  user_property = "email"
  friendly_name = "email"
  saml_attribute_name = "urn:oid:1.2.840.113549.1.9.1"
  saml_attribute_name_format = "URI Reference"
}

resource "keycloak_saml_user_property_protocol_mapper" "property_givenname" {
  realm_id = keycloak_realm.realm.id
  client_id = keycloak_saml_client.client.id
  name = "X500 givenName"
  user_property = "firstName"
  friendly_name = "givenName"  
  saml_attribute_name = "urn:oid:2.5.4.42"
  saml_attribute_name_format = "URI Reference"
}

resource "keycloak_saml_user_property_protocol_mapper" "property_surname" {
  realm_id = keycloak_realm.realm.id
  client_id = keycloak_saml_client.client.id
  name = "X500 surname"
  user_property = "lastName"
  friendly_name = "surname"  
  saml_attribute_name = "urn:oid:2.5.4.4"
  saml_attribute_name_format = "URI Reference"
}

# Keycloak test user account
resource "keycloak_user" "test_user" {
  realm_id = keycloak_realm.realm.id
  username = var.kc_user.name
  enabled = true
  first_name = var.kc_user.name
  last_name = var.kc_user.name
  email = "${var.kc_user.name}@${var.kc_user.domain}"
  attributes = {}
  initial_password {
    value = var.kc_user.pass
    temporary = false
  }
}
