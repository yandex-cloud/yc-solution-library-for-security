# =====================
# Keycloak VM resources
# =====================

data "yandex_resourcemanager_folder" "kc_folder" {
  cloud_id = var.cloud_id
  name = var.kc_folder_name
}

# Define a Keycloak image-id
data "yandex_compute_image" "kc_image" {
  name = var.kc_image_name
  folder_id = var.kc_image_folder_id
}

# Create Service Account (SA) for Keycloak VM
resource "yandex_iam_service_account" "kc_sa" {
  name = "${var.kc_hostname}-sa"
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  description = "for using on Keycloak's VM"
}

# Grant SA access to download certificates from Certificate Manager (CM)
resource "yandex_resourcemanager_folder_iam_member" "cm_cert_download" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  role = "certificate-manager.certificates.downloader"
  member = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}

# Grant SA access to Keycloak's VM metadata
resource "yandex_resourcemanager_folder_iam_member" "rm_viewer" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  role = "resource-manager.viewer"
  member = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}

# Grant SA access to Keycloak's VM metadata
resource "yandex_resourcemanager_folder_iam_member" "compute_viewer" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  role = "compute.viewer"
  member = "serviceAccount:${yandex_iam_service_account.kc_sa.id}"
}


# Create Keycloak VM
resource "yandex_compute_instance" "kc_vm" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.kc_hostname
  hostname = var.kc_hostname
  platform_id = "standard-v3"
  zone = var.kc_zone_id
  service_account_id = "${yandex_iam_service_account.kc_sa.id}"

  resources {
    cores  = 2
    memory = 8
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.kc_image.id
      type = "network-ssd"
      size = 80
    }
  }
  
  network_interface {
    subnet_id = "${data.yandex_vpc_subnet.kc_subnet.id}"
    nat = true
    nat_ip_address = "${yandex_vpc_address.kc_pub_ip.external_ipv4_address[0].address}"
    security_group_ids = [ yandex_vpc_security_group.kc_sg.id ]
  }
  
  metadata = {
    user-data = templatefile("${abspath(path.module)}/kc-vm-init.tpl", {
      username = "${chomp(var.kc_vm_username)}",
      ssh_key = "${chomp(var.kc_vm_ssh_key_file)}"
    })
  }

  # Prepare input data for Keycloak VM provisioning script
  provisioner "file" {
    destination = "kc-data.sh"
    content = <<EOF
      export KC_FQDN=${local.kc_fqdn}
      export KC_VER=${var.kc_ver}
      export KC_PORT=${var.kc_port}
      export KC_ADM_USER=${var.kc_adm_user}
      export KC_ADM_PASS=${var.kc_adm_pass}
      export KC_CERT_PATH=${var.kc_cert_path}
      export PG_DB_HOST=${yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn}
      export PG_DB_NAME=${var.pg_db_name}
      export PG_DB_USER=${var.pg_db_user}
      export PG_DB_PASS=${var.pg_db_pass}
      export KC_CERT_NAME=${var.le_cert_name}
      export KC_CERT_PUB=${var.le_cert_pub_chain}
      export KC_CERT_PRIV=${var.le_cert_priv_key}
    EOF
  }

  # Keyclock VM provisioning script
  provisioner "file" {
    source = "${abspath(path.module)}/kc-setup.sh"
    destination = "kc-setup.sh"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    host = "${yandex_vpc_address.kc_pub_ip.external_ipv4_address[0].address}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash kc-setup.sh"
    ]
  }

  depends_on = [ yandex_mdb_postgresql_database.pg_db ]
}
