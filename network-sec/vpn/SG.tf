
resource "yandex_vpc_security_group" "sg-ipsec" {
  name        = "sg-ipsec"
  description = "allows traffic in and out of tunnel and tunnel itself"
  network_id  = yandex_vpc_network.vpc-infra.id



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
    protocol       = "UDP"
    description    = "ipsec_peer_allow_4500"
    v4_cidr_blocks = formatlist("%s/32", [yandex_vpc_address.remoteaddr.external_ipv4_address.0.address])
    port      = 4500
  }

  ingress {
    protocol       = "UDP"
    description    = "ipsec_peer_allow_500"
    v4_cidr_blocks = formatlist("%s/32", [yandex_vpc_address.remoteaddr.external_ipv4_address.0.address])
    port      = 500
  }


  egress {
    protocol       = "ANY"
    description    = "egress_internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "sg-frontend" {
  name        = "sg-frontend"
  description = "allows traffic to ngnix, and remote access from vpn"
  network_id  = yandex_vpc_network.vpc-infra.id


  ingress {
    protocol       = "TCP"
    description    = "allow-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "allow-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }


  ingress {
    protocol       = "TCP"
    description    = "allow-ssh"
    v4_cidr_blocks = ["192.168.0.0/24"]
    port           = 22
  }

  ingress {
  protocol          = "ANY"
  description       = "p2p"
  predefined_target = "self_security_group"
}

  egress {
    protocol       = "ANY"
    description    = "egress_internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "sg-backend" {
  name        = "sg-backend"
  description = "allows traffic backend"
  network_id  = yandex_vpc_network.vpc-infra.id


  ingress {
    protocol       = "TCP"
    description    = "allow-mongo-frontend"
    security_group_id  = yandex_vpc_security_group.sg-frontend.id
    port           = 27017
  }

  ingress {
    protocol       = "TCP"
    description    = "allow-mongo-remote"
    v4_cidr_blocks = ["192.168.0.0/24"]
    port           = 27017
  }

  ingress {
    protocol       = "TCP"
    description    = "allow-ssh"
    v4_cidr_blocks = ["192.168.0.0/24"]
    port           = 22
  }

  ingress {
  protocol          = "ANY"
  description       = "p2p"
  predefined_target = "self_security_group"
}

  egress {
    protocol       = "ANY"
    description    = "egress_internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
