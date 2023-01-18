# ===================================
# DNS & Certificate Manager resources
# ===================================

data "yandex_dns_zone" "kc_dns_zone" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.dns_zone_name
}

locals {
  kc_fqdn = "${var.kc_hostname}.${trimsuffix(data.yandex_dns_zone.kc_dns_zone.zone,".")}"
}

# Create DNS record for Keycloak VM with created public ip address
resource "yandex_dns_recordset" "kc_dns_rec" {
  zone_id = data.yandex_dns_zone.kc_dns_zone.id
  name = var.kc_hostname
  type = "A"
  ttl = 300
  data = ["${yandex_vpc_address.kc_pub_ip.external_ipv4_address[0].address}"]
}

# Create request to the Let's Encrypt service for Keycloak's VM certificate
resource "yandex_cm_certificate" "kc_le_cert" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.le_cert_name
  domains = [ "${local.kc_fqdn}" ]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

# Create domain validation DNS record for Let's Encrypt service
resource "yandex_dns_recordset" "validation_dns_rec" {
  zone_id = data.yandex_dns_zone.kc_dns_zone.id
  name = yandex_cm_certificate.kc_le_cert.challenges[0].dns_name
  type = yandex_cm_certificate.kc_le_cert.challenges[0].dns_type
  data = [yandex_cm_certificate.kc_le_cert.challenges[0].dns_value]
  ttl = 60
}

output "kc_fqdn" {
  value = local.kc_fqdn
}
