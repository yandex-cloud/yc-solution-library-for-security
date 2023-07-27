# DNS record for Keycloak
resource "yandex_dns_recordset" "kc_dns_rec" {
  zone_id = var.values.dns_zone_id
  name    = "${var.values.keycloak.subdomain}"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.kc_pub_ip.external_ipv4_address[0].address}"]
}

# Create public ip address for Keycloak VM
resource "yandex_vpc_address" "kc_pub_ip" {
  folder_id = var.values.folder_id
  name      = "${var.values.keycloak.subdomain}-public-ip"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Create subnet for Keycloak VM
resource "yandex_vpc_subnet" "kc_subnet" {
  folder_id = var.values.folder_id
  name           = "keycloak"
  zone           = "ru-central1-a"
  network_id     = var.values.vpc_id
  v4_cidr_blocks = [var.values.keycloak.subnet]
}
