
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
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 80
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 443
  }
  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.ssh-broker.id
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol       = "TCP"
    predefined_target = "self_security_group"
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
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.ptaf-sg.id
    port      = 80
  }
  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.ptaf-sg.id
    port      = 443
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
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


resource "yandex_vpc_security_group" "ssh-broker" {
  folder_id = var.folder_id
  name       = "broker-sg"
  network_id = data.yandex_vpc_network.vpc-positive.id
  ingress {
    protocol       = "TCP"
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


//Создание LB_target_group ptaf
resource "yandex_lb_target_group" "ptaf_group" {
  name      = "ptafgroup"

  target {
    subnet_id = yandex_vpc_subnet.ext-subnet[0].id
    address   = yandex_compute_instance.ptaf[0].network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.ext-subnet[1].id
    address   = yandex_compute_instance.ptaf[1].network_interface.0.ip_address
  }
}




//Объявление extLB для импорта
resource "yandex_lb_network_load_balancer" "ext-lb" {
  name = "extlb"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.ptaf_group.id}"

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 22013
      }
    }
  }

  
}

//data target-group app
data "yandex_lb_target_group" "app-group" {
  target_group_id = var.app_target_group_id
}

//Создание intLB 
resource "yandex_lb_network_load_balancer" "int-lb" {
  name = "intlb"
  type = "internal"
  depends_on = [
    yandex_lb_network_load_balancer.ext-lb,
  ]

  listener {
    name = "my-listener"
    port = 80
    internal_address_spec {
      subnet_id  = yandex_vpc_subnet.ext-subnet[0].id
    }
  }

  attached_target_group {
    target_group_id = data.yandex_lb_target_group.app-group.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }

  
}


