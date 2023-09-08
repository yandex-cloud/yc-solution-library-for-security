# ==============================
# Certificate Manager resources
# Let's Encrypt certificate 
# ==============================

# Create request to the Let's Encrypt service for Keycloak's VM certificate
resource "yandex_cm_certificate" "kc_le_cert" {
  folder_id   = var.values.folder_id
  name        = var.values.keycloak.le_cert_name
  domains     = ["${var.values.keycloak.subdomain}.${var.values.domain}"]
  description = "LE Certificate for Keycloak VM"
  managed {
    challenge_type = "DNS_CNAME"
  }
}

# Create domain validation DNS record for Let's Encrypt service
resource "yandex_dns_recordset" "validation_dns_rec" {
  zone_id = var.values.dns_zone_id
  name    = yandex_cm_certificate.kc_le_cert.challenges[0].dns_name
  type    = yandex_cm_certificate.kc_le_cert.challenges[0].dns_type
  data    = [yandex_cm_certificate.kc_le_cert.challenges[0].dns_value]
  ttl     = 60
}

# Still waiting upon the cert will be issued (up to 30 min!)
data "yandex_cm_certificate_content" "cert_check_status" {
  folder_id          = var.values.folder_id
  name               = var.values.keycloak.le_cert_name
  wait_validation    = true
  private_key_format = "PKCS1" 
  depends_on         = [yandex_dns_recordset.validation_dns_rec]
}

# Save generated public keys chain to the specified file
resource "local_file" "kc_pub_chain" {
  content    = join("", [for el in data.yandex_cm_certificate_content.cert_check_status.certificates : format("%s", el)])
  filename   = "le-cert-pub-chain.pem"
  depends_on = [data.yandex_cm_certificate_content.cert_check_status]
}

# Save generated private key to the specified file
resource "local_file" "kc_private_key" {
  content    = data.yandex_cm_certificate_content.cert_check_status.private_key
  filename   = "le-cert-priv-key.pem"
  depends_on = [data.yandex_cm_certificate_content.cert_check_status]
}
