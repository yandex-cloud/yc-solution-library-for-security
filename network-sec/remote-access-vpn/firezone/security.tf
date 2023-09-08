// Create security group for firezone control server
resource "yandex_vpc_security_group" "firezone-sg" {
  name        = "firezone-sg"
  description = "Security group for Firezone"
  folder_id   = var.values.folder_id
  network_id  = var.values.vpc_id

  ingress {
    protocol            = "TCP"
    description         = "For automatically issuing SSL certificates"
    port                = 80
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol            = "TCP"
    description         = "HTTPS access to Firezone web portal"
    port                = 443
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol            = "TCP"
    description         = "SSH from trusted public IP addresses"
    port                = 22
    v4_cidr_blocks      = var.values.trusted_ip_for_mgmt
  }

  ingress {
    protocol            = "UDP"
    description         = "WireGuard VPN"
    port                = var.values.firezone.wg_port
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol            = "ICMP"
    description         = "ICMP from trusted public IP addresses"
    v4_cidr_blocks      = var.values.trusted_ip_for_mgmt
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create security group for PostgreSQL cluster
resource "yandex_vpc_security_group" "postgres-sg" {
  name        = "postgres-sg"
  description = "Security group for PostgreSQL"
  folder_id   = var.values.folder_id
  network_id  = var.values.vpc_id

  ingress {
    protocol            = "TCP"
    description         = "PostgreSQL"
    port                = 6432
    v4_cidr_blocks      = [var.values.firezone.subnet, var.values.keycloak.subnet]
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

