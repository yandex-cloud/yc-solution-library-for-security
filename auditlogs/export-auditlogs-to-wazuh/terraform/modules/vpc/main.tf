resource "yandex_vpc_network" "this" {
  name = var.vpc_name

  labels = var.labels
}

resource "yandex_vpc_subnet" "this" {
  for_each = var.vpc_subnets

  network_id     = yandex_vpc_network.this.id
  name           = each.key
  v4_cidr_blocks = [each.value.cidr]
  zone           = each.value.zone

  labels = var.labels
}
