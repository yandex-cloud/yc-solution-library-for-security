resource "yandex_vpc_network" "vpc-infra" {
  name = "vpc-infra"
}

resource "yandex_vpc_route_table" "rt-inet" {
  name = "rt-inet"
  network_id = yandex_vpc_network.vpc-infra.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "10.0.0.5"
  }
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.0.0.0/24"]

}

resource "yandex_vpc_subnet" "tools-subnet" {
  name           = "tools-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.50.0.0/24"]
  route_table_id = yandex_vpc_route_table.rt-inet.id
}

resource "yandex_vpc_subnet" "subnet-dev" {
  name           = "subnet-dev"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.30.0.0/24"]
  folder_id = var.dev_folder_id
}

resource "yandex_vpc_subnet" "subnet-stage" {
  name           = "subnet-stage"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.20.0.0/24"]
  route_table_id = yandex_vpc_route_table.rt-inet.id
  folder_id = var.stage_folder_id
}

resource "yandex_vpc_subnet" "subnet-prod" {
  name           = "subnet-prod"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-infra.id
  v4_cidr_blocks = ["10.10.0.0/24"]
  folder_id = var.prod_folder_id
}
