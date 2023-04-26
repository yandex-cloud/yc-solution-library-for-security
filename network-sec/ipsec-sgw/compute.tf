# =================
# Compute Resources
# =================

# Define SGW Folder
data "yandex_resourcemanager_folder" "sgw_folder" {
  cloud_id = var.cloud_id
  name     = var.yc_sgw.folder_name
}

# Define the VM image for SGW
data "yandex_compute_image" "sgw_image" {
  folder_id = var.yc_sgw.image_folder_id
  name      = var.yc_sgw.image_name
  # family = container-optimized-image
}

# Create SGW VM
resource "yandex_compute_instance" "sgw" {
  folder_id   = data.yandex_resourcemanager_folder.sgw_folder.id
  name        = lower(var.yc_sgw.name)
  hostname    = lower(var.yc_sgw.name)
  platform_id = "standard-v3"
  zone        = var.yc_sgw.zone
  labels      = var.labels
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.sgw_image.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.sgw_subnet.id
    ip_address         = var.yc_sgw.inside_ip
    nat                = true
    nat_ip_address     = yandex_vpc_address.sgw_public_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.sgw_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/sgw-vm-init.tpl", {
      ADMIN_NAME    = var.yc_sgw.admin_name
      ADMIN_SSH_KEY = file(var.yc_sgw.admin_key_path)

      REMOTE_SGW_IP = var.remote_sgw.outside_ip
      POLICY_NAME   = var.ipsec_policy.policy_name
      IKE_PROPOSAL  = var.ipsec_policy.ike_proposal
      ESP_PROPOSAL  = var.ipsec_policy.esp_proposal
      PSK           = var.ipsec_policy.psk

      ROUTE_LIST = trim("%{for prefix in var.remote_subnets}ip route add ${prefix} dev ipsec0;%{~endfor~}", ";")
    })
  }
}
