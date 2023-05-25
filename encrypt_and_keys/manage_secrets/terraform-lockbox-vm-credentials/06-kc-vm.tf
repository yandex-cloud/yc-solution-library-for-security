data "yandex_compute_image" "vm_image" {
  family = var.image_family
}

#Create KeyCloak VM
 
resource "yandex_compute_instance" "keycloak" {
  name     = var.keycloak_name
  hostname = var.keycloak_name
  zone     = var.zone
  platform_id = var.platform_id
  service_account_id = yandex_iam_service_account.kc-sa.id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image.id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.keycloaksubnet[0].id
    nat       = var.nat
  }

  metadata = {
    user-data = templatefile("${path.module}/kc-install.yml",
    {
      ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
      DomainFQDN = var.domain_fqdn
      KC_VER = var.kc_ver
      KC_PORT = var.kc_port
      PG_DB_HOST = yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn
      PG_DB_NAME = var.pg_db_name
      SA_NAME = yandex_iam_service_account.kc-sa.name
      SECRET_ID = yandex_lockbox_secret.password_secret.id
    }
    )
  }

  depends_on = [
    local_file.private_key,
    yandex_mdb_postgresql_cluster.pg_cluster,
    yandex_mdb_postgresql_database.pg_db,
    yandex_kms_symmetric_key.kc-key,
    yandex_iam_service_account.kc-sa,
    yandex_lockbox_secret.password_secret,
    null_resource.lockbox_secrets_access_binding
  ]
}

output "keycloak_name" {
  value = yandex_compute_instance.keycloak.name
}

output "keycloak_address" {
  value = yandex_compute_instance.keycloak.network_interface.0.nat_ip_address
}

output "public_key" {
  value = chomp(tls_private_key.ssh.public_key_openssh)
}