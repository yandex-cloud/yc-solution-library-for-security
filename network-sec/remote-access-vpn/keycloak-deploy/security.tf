# Create Security Group for Keycloak VM
resource "yandex_vpc_security_group" "kc_sg" {
  name       = "kc_sg"
  description = "Security group for Keycloak"
  folder_id  = var.values.folder_id
  network_id = var.values.vpc_id

  egress {
    description    = "Permit ALL"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = var.values.trusted_ip_for_mgmt
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.values.trusted_ip_for_mgmt
  }

  ingress {
    description    = "https"
    protocol       = "TCP"
    port           = var.values.keycloak.port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
