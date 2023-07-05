# ===============
# VPC Resources
# ===============

resource "yandex_vpc_network" "win-network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "win-subnet" {
  count = length(var.net_cidr)
  name = var.net_cidr[count.index].name
  zone = var.net_cidr[count.index].zone
  v4_cidr_blocks = [var.net_cidr[count.index].prefix]
  network_id = "${yandex_vpc_network.win-network.id}"
}