# ============================================================
# Example of using IPsec-SGW Terraform module for Yandex Cloud
# ============================================================

# ==================================
# Terraform & Provider Configuration
# ==================================
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.89.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# =====================
# Call IPsec-SGW module
# =====================
module "ipsec-sgw" {
  source    = "../"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  labels    = { tag = "ipsec-sgw" }

  # ==================================================================
  # IPsec profile for both sides (strongSwan keywords values)
  # https://docs.strongswan.org/docs/5.9/config/IKEv2CipherSuites.html
  # ==================================================================
  ipsec_policy = {
    policy_name  = "yc-ipsec"
    ike_proposal = "aes128gcm16-prfsha256-ecp256"
    esp_proposal = "aes128gcm16"
    psk          = "Sup@385paS4"
  }

  # =================================
  # Yandex Cloud side: strongSwan SGW
  # =================================
  yc_subnets = {
    net_name             = "default"
    rt_name              = "sgw-rt"
    rt_internet_access   = false
    force_subnets_update = false
    prefix_list          = ["10.128.0.0/24", "10.129.0.0/24"]
  }

  yc_sgw = {
    name            = "yc-sgw"
    folder_name     = "folder1"
    image_folder_id = "b1g4n62gio32v96mdvrb"
    image_name      = "ipsec-sgw"
    zone            = "ru-central1-a"
    subnet          = "192.168.200.0/24"
    inside_ip       = "192.168.200.10"
    admin_name      = "admin"
    admin_key_path  = "~/.ssh/id_ed25519.pub"
  }

  # =================================
  # Remote side: 3rd party IPsec SGW
  # =================================
  remote_subnets = ["10.10.201.0/24", "10.10.202.0/24"]

  remote_sgw = {
    name       = "Router1"
    type       = "cisco-iosxe"
    outside_ip = "51.250.13.97"
  }
}

output "yc_rt_cmd" {
  description = "yc cli command for update the routing table."
  value       = module.ipsec-sgw.yc_rt_cmd
}
