//Создание сети
resource "yandex_vpc_network" "vpc-positive" {
  name = "vpc-infra"
}
//Создание подсетей
resource "yandex_vpc_subnet" "mgmgt-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "mgmt-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.mgmt_cidrs, count.index)]
}

resource "yandex_vpc_subnet" "app-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "app-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.app_cidrs, count.index)]
}

resource "yandex_vpc_subnet" "ext-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "ext-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.ext_cidrs, count.index)]
}



//Создание Security Group
resource "yandex_vpc_security_group" "sg-vpc-kasper" {
  folder_id = var.folder_id
  name       = "sg-any"
  network_id = yandex_vpc_network.vpc-positive.id
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

