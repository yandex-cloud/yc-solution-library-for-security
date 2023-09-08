// Create ssh keys for compute resources
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "pt_key.pem"
  file_permission = "0600"
}

resource "random_string" "firezone_admin_password" {
  length  = 12
  upper   = true
  lower   = true
  numeric  = true
  special = true
  override_special = "!@%&*()-_=+[]{}<>:?"
}

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

// Create firezone control server
resource "yandex_compute_instance" "firezone" {
  folder_id = var.values.folder_id
  name        = "firezone"
  hostname    = "firezone"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      type     = "network-ssd"
      size     = 30
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.firezone-subnet.id
    ip_address = "${cidrhost(var.values.firezone.subnet, 100)}"
    nat                = true
    nat_ip_address = yandex_vpc_address.firezone-public-ip.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.firezone-sg.id] 
  }

  metadata = {
    user-data = templatefile("${path.module}/templates/cloud-init_firezone.tpl.yaml",
    {
      firezone_ssh_key_pub = "${chomp(tls_private_key.ssh.public_key_openssh)}",
      firezone_vm_username = var.values.firezone.vm_username
      firezone_admin_email = var.values.firezone.admin_email
      firezone_admin_password = "${random_string.firezone_admin_password.result}"
      firezone_url = "https://${var.values.firezone.subdomain}.${var.values.domain}"
      version = var.values.firezone.version
      db_host = yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn 
      db_name = var.values.postgres.db_firezone_name
      db_user = var.values.postgres.db_user
      db_pass = random_string.postgres_user_password.result
      wg_port = var.values.firezone.wg_port
    })
  }
  depends_on = [yandex_mdb_postgresql_database.pg_firezone_db]
}
