resource "yandex_vpc_network" "remote-admin" {
  name = "remote-admin"
}
resource "yandex_vpc_route_table" "route-to-cloud" {
  name = "route-to-cloud"
  network_id = yandex_vpc_network.remote-admin.id

  static_route {
    destination_prefix = "10.0.0.0/8"
    next_hop_address   = "192.168.0.5"
  }
}

resource "yandex_vpc_subnet" "remote-a" {
  name           = "remote-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.remote-admin.id
  v4_cidr_blocks = ["192.168.0.0/24"]

}
data "yandex_compute_image" "my_vpn" {
  family = "ipsec-instance-ubuntu"
}

resource "yandex_vpc_security_group" "sg-remote" {
  name        = "sg-remote"
  description = "allows traffic in and out of tunnel and tunnel itself"
  network_id  = yandex_vpc_network.remote-admin.id



  ingress {
    protocol       = "TCP"
    description    = "internal_net_ssh"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "internal_icmp"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/24"]
  }

  ingress {
  protocol          = "ANY"
  description       = "p2p"
  predefined_target = "self_security_group"
}

  ingress {
    protocol       = "UDP"
    description    = "ipsec_peer_allow_4500"
    v4_cidr_blocks = formatlist("%s/32", [yandex_vpc_address.vpnaddr.external_ipv4_address.0.address])
    port      = 4500
  }

  ingress {
    protocol       = "UDP"
    description    = "ipsec_peer_allow_500"
    v4_cidr_blocks = formatlist("%s/32", [yandex_vpc_address.vpnaddr.external_ipv4_address.0.address])
    port      = 500
  }


  ingress {
    protocol          = "TCP"
    description       = "p2p"
    v4_cidr_blocks = var.remote_whitelist_ip
    port              = "22"
  }

  egress {
    protocol       = "ANY"
    description    = "egress_internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

data "template_file" "remote_init" {
  template = "${file("remote-init.tpl.yaml")}"
  vars =  {

        ssh_key = "${file(var.public_key_path)}"
        vpn_addr = yandex_vpc_address.vpnaddr.external_ipv4_address.0.address
        remote_addr = yandex_vpc_address.remoteaddr.external_ipv4_address.0.address
        ipsec_pass = var.ipsec_password
    }
}

resource "yandex_vpc_address" "remoteaddr" {
  name = "remoteaddr"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
resource "yandex_compute_instance" "remote-vpn" {
  zone        = "ru-central1-a"
  name        = "remote-vpn"
  hostname    = "remote-vpn"
  platform_id = "standard-v2"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_vpn.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.remote-a.id
    ip_address = "192.168.0.5"
    nat = true
    nat_ip_address = yandex_vpc_address.remoteaddr.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.sg-remote.id]
}

metadata = {
  user-data = "${data.template_file.remote_init.rendered}"
  serial-port-enable = 1
}
}
