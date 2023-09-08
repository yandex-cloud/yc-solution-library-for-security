# Define a Keycloak image-id
data "yandex_compute_image" "kc_image" {
  name      = var.values.keycloak.image_name
  folder_id = var.values.keycloak.image_folder_id
}

# Create Service Account (SA) for Keycloak VM
resource "yandex_iam_service_account" "kc_sa" {
  name        = "${var.values.keycloak.subdomain}-sa"
  folder_id   = var.values.folder_id
  description = "for using on Keycloak's VM"
}

# Grant SA access to download certificates from Certificate Manager (CM)
resource "yandex_resourcemanager_folder_iam_member" "cm_cert_download" {
  folder_id = var.values.folder_id
  role      = "certificate-manager.certificates.downloader"
  member    = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}

# Grant SA access to Keycloak's VM metadata
resource "yandex_resourcemanager_folder_iam_member" "rm_viewer" {
  folder_id = var.values.folder_id
  role      = "resource-manager.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "compute_viewer" {
  folder_id = var.values.folder_id
  role      = "compute.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}

# Generate Keycloak admin password
resource "random_string" "keycloak_admin_password" {
  length  = 12
  upper   = true
  lower   = true
  numeric  = true
  special = true
  override_special = "!@%&*()-_=+[]{}<>:?"
}

# Create Keycloak VM
resource "yandex_compute_instance" "kc_vm" {
  folder_id          = var.values.folder_id
  name               = var.values.keycloak.subdomain
  hostname           = var.values.keycloak.subdomain
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  service_account_id = yandex_iam_service_account.kc_sa.id

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.kc_image.id
      type     = "network-ssd"
      size     = 80
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kc_subnet.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.kc_pub_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.kc_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/templates/kc-vm-init.tpl", {
      ADMIN_NAME        = "${var.values.keycloak.vm_username}"
      ADMIN_SSH_KEY     = "${chomp(var.values.ssh_pub_key)}"
      KC_FQDN           = "${var.values.keycloak.subdomain}.${var.values.domain}"
      KC_PORT           = "${var.values.keycloak.port}"
      KC_ADM_USER       = "${var.values.keycloak.admin_user}"
      KC_ADM_PASS       = "${random_string.keycloak_admin_password.result}"
      PG_DB_HOST        = "${var.values.pg_fqdn}"
      PG_DB_NAME        = "${var.values.postgres.db_kc_name}"
      PG_DB_USER        = "${var.values.postgres.db_user}"
      PG_DB_PASS        = "${var.values.pg_pass}"
      KC_CERT_NAME      = "${var.values.keycloak.le_cert_name}"
      KC_CERT_PUB       = "le-cert-pub-chain.pem"
      KC_CERT_PRIV      = "le-cert-priv-key.pem"
      KC_CERT_PUB_DATA  = "${base64encode(local_file.kc_pub_chain.content)}"
      KC_CERT_PRIV_DATA = "${base64encode(local_file.kc_private_key.content)}"
    })
  }
}
