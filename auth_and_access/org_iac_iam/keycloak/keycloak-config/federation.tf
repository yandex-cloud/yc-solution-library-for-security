# ========================================================
# YC Federation resource
# Import Keycloak resources into Federation & Organization
# ========================================================

# Create YC Federation
resource "yandex_organizationmanager_saml_federation" kc_fed {
  name = var.fed_name
  organization_id = var.org_id
  issuer = "https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm_name}"
  sso_url = "https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm_name}/protocol/saml"
  sso_binding = "POST"
  auto_create_account_on_login = true
  security_settings {
    encrypted_assertions = true
  }
}

# Add Keycloak certificate to the YC Federation
resource "null_resource" "federation_cert" {
  provisioner "local-exec" {
    command = <<-CMD
    echo -----BEGIN CERTIFICATE-----\\n $(curl -s https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm_name}/protocol/saml/descriptor | awk '{split($0,lst,"X509Certificate>"); print substr(lst[2],1,length(lst[2])-5)}')\\n-----END CERTIFICATE----- | tee ${abspath(path.cwd)}/${var.kc_realm_name}-cert.pem
    
    yc organization-manager federation saml certificate create \
    --name=${var.fed_name} \
    --federation-id=${yandex_organizationmanager_saml_federation.kc_fed.id} \
    --certificate-file=${abspath(path.cwd)}/${var.kc_realm_name}-cert.pem
    CMD
  }
  depends_on = [
    keycloak_realm.realm
  ]
}

# Import Test user account to YC Organization from Keycloak
data "yandex_organizationmanager_saml_federation_user_account" kc_test_user {
  federation_id = "${yandex_organizationmanager_saml_federation.kc_fed.id}"
  name_id = var.kc_user.name

  depends_on = [
    null_resource.federation_cert
  ]
}

output "federation_url" {
  value = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.kc_fed.id}"
}
