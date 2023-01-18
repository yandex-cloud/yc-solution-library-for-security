# =============
# VPC resources
# =============

# Define Keycloak Network
data "yandex_vpc_network" "kc_net" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.kc_network_name
}

# Define Keycloak Subnet
data "yandex_vpc_subnet" "kc_subnet" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.kc_subnet_name
}

# Create public ip address for Keycloak VM
resource "yandex_vpc_address" "kc_pub_ip" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.kc_hostname
  external_ipv4_address {
    zone_id = var.kc_zone_id
  }
}

# Create Security Group for Keycloak VM
resource "yandex_vpc_security_group" "kc_sg" {
  name = var.kc_vm_sg_name
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  network_id = "${data.yandex_vpc_network.kc_net.id}"

  egress {
    description    = "Permit ALL" 
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "https"
    protocol       = "TCP"
    port           = var.kc_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
