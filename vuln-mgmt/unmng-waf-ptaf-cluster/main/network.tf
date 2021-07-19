
data "yandex_vpc_network" "vpc-positive" {
  network_id = var.vpc_id
}

resource "yandex_vpc_subnet" "ext-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "ext-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = data.yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.ext_cidrs, count.index)]
}


resource "yandex_vpc_subnet" "mgmgt-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "mgmt-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = data.yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.mgmt_cidrs, count.index)]
}




//Создание Security Group
resource "yandex_vpc_security_group" "ptaf-sg" {
  folder_id = var.folder_id
  name       = "ptaf-sg"
  network_id = data.yandex_vpc_network.vpc-positive.id
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 80
  }
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 443
  }
  ingress {
    protocol       = "ANY"
    security_group_id = yandex_vpc_security_group.ssh-broker.id
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


resource "yandex_vpc_security_group" "app-sg" {
  folder_id = var.folder_id
  name       = "apps-sg"
  network_id = data.yandex_vpc_network.vpc-positive.id
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 80
  }
  ingress {
    protocol       = "ANY"
    security_group_id = yandex_vpc_security_group.ptaf-sg.id
    port      = 443
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}


resource "yandex_vpc_security_group" "ssh-broker" {
  folder_id = var.folder_id
  name       = "broker-sg"
  network_id = data.yandex_vpc_network.vpc-positive.id
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}