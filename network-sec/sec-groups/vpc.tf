resource "yandex_vpc_network" "vpc-infra" {
  name = "vpc-infra"
}

resource "yandex_vpc_route_table" "route-to-remote" {
  name = "route-to-remote"
  network_id = yandex_vpc_network.vpc-infra.id

  static_route {
    destination_prefix = "192.168.0.0/24"
    next_hop_address   = "10.10.5.5"
  }
}

resource "yandex_vpc_subnet" "frontend-subnet-a" {
  name           = "frontend-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.240.1.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}

resource "yandex_vpc_subnet" "frontend-subnet-b" {
  name           = "frontend-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.240.2.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}

resource "yandex_vpc_subnet" "frontend-subnet-c" {
  name           = "frontend-subnet-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.240.3.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}


resource "yandex_vpc_subnet" "vpn-subnet-a" {
  name           = "vpn-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.10.5.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}

resource "yandex_vpc_subnet" "backend-subnet-a" {
  name           = "backend-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.110.1.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}

resource "yandex_vpc_subnet" "backend-subnet-b" {
  name           = "backend-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.110.2.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}

resource "yandex_vpc_subnet" "backend-subnet-c" {
  name           = "backend-subnet-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.110.3.0/24"]
  route_table_id = yandex_vpc_route_table.route-to-remote.id
}
