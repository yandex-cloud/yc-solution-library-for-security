resource "yandex_vpc_address" "firezone-public-ip" {
  name = "pfirezone-public-ip"
  folder_id = var.values.folder_id
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_subnet" "firezone-subnet" {
  folder_id = var.values.folder_id
  name           = "firezone"
  zone           = "ru-central1-a"
  network_id     = var.values.vpc_id
  v4_cidr_blocks = [var.values.firezone.subnet]
}

resource "yandex_dns_zone" "firezone-zone" {
  folder_id = var.values.folder_id
  name        = "firezone-zone"
  description = "Public zone for Firezone VPN"
  zone             = "${var.values.domain}."
  public           = true
}

resource "yandex_dns_recordset" "firezone-dns-rec" {
  zone_id = yandex_dns_zone.firezone-zone.id
  name    = "${var.values.firezone.subdomain}"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.firezone-public-ip.external_ipv4_address.0.address}"]
}




