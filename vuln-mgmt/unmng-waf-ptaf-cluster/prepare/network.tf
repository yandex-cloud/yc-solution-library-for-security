//Создание сети
resource "yandex_vpc_network" "vpc-positive" {
  name = "vpc-infra"
}
//Создание подсетей

resource "yandex_vpc_subnet" "app-subnet" {
  folder_id = var.folder_id

  count          = 2
  name           = "app-subnet-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-positive.id
  v4_cidr_blocks = [element(var.app_cidrs, count.index)]
}


resource "yandex_vpc_address" "ext-address" {
  name = "ext-address"

  external_ipv4_address {
    ddos_protection_provider = "qrator"
    zone_id                  = "ru-central1-a"
  }
}

//Создание LB_target_groupd
resource "yandex_lb_target_group" "apps_group" {
  name      = "appsgroup"

  target {
    subnet_id = yandex_vpc_subnet.app-subnet[0].id
    address   = yandex_compute_instance.instance-based-on-coi[0].network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.app-subnet[1].id
    address   = yandex_compute_instance.instance-based-on-coi[1].network_interface.0.ip_address
  }
}

//Создание LB
resource "yandex_lb_network_load_balancer" "ext-lb" {
  name = "extlb"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
      address = yandex_vpc_address.ext-address.external_ipv4_address.0.address
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.apps_group.id}"

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}


