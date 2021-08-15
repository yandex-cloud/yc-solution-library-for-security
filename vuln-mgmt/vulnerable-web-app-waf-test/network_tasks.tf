resource "yandex_vpc_network" "network-dvwa" {
  name = "network1"
}

resource "yandex_vpc_subnet" "dvwa-subnet" {
  name           = "dvwa-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-dvwa.id
  v4_cidr_blocks = ["192.168.11.0/24"]  
}

resource "yandex_vpc_address" "dvwa-address" {
  name = "dvwa-address"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_security_group" "sg-dvwa" {
  name        = "sg-dvwa"
  description = "allows traffic"
  network_id  = yandex_vpc_network.network-dvwa.id

  ingress {
    protocol       = "TCP"
    description    = "allow-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

 ingress {
    protocol       = "TCP"
    description    = "allow-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "egress_internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}



