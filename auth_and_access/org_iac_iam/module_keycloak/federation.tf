# =======================
# YC Federation Resources
# =======================

resource "yandex_organizationmanager_saml_federation" federation {
  name = "keycloak"
  description = "Keycloak Federation"
  organization_id = var.org_id
  issuer = "https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm}"
  sso_url = "https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm}/protocol/saml"
  sso_binding = "POST"
  auto_create_account_on_login = true
  security_settings {
    encrypted_assertions = true
  }
}

resource "null_resource" "federation_cert" {
  provisioner "local-exec" {
    command = <<-CMD
    echo -----BEGIN CERTIFICATE-----\\n$(curl -s https://${var.kc_fqdn}:${var.kc_port}/realms/${var.kc_realm}/protocol/saml/descriptor | awk '{split($0,lst,"X509Certificate>"); print substr(lst[2],1,length(lst[2])-5)}')\\n-----END CERTIFICATE----- | tee kc-cert.pem
    
    yc organization-manager federation saml certificate create \
    --name=kc-cert \
    --federation-id=${yandex_organizationmanager_saml_federation.federation.id} \
    --certificate-file=kc-cert.pem
    
    rm -f kc-cert.pem
    CMD
  }

 depends_on = [
   yandex_compute_instance.vm_instance
 ]
}

output "federation_link" {
  value     = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.federation.id}" 
}

output "keycloak_links" {
  value     = "https://${var.kc_fqdn}:8443"
}

output "federation_id" {
  value     = yandex_organizationmanager_saml_federation.federation.id
}