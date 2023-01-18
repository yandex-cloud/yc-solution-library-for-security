# ==================================
# Terraform & Provider Configuration
# ==================================
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84.0"
    }
  }
}

# ===========================
# Call keycloak-deploy module
# ===========================
module "keycloak-deploy" {
  source = "https://github.com/nettworker/yc-solution-library-for-security/tree/master/auth_and_access/keycloak/keycloak-deploy/"
  cloud_id = var.YC_CLOUD_ID
  labels = { tag = "keycloak-deploy" }

  # ==================
  # Keycloak VM values
  # ==================
  kc_image_folder_id = "standard-images"
  kc_image_name = "ubuntu-22-04-lts-v20221226"

  kc_folder_name = "infra"
  kc_zone_id = "ru-central1-b"
  kc_network_name = "infra-net"
  kc_subnet_name = "infra-subnet-b"  

  kc_hostname = "kc1"
  kc_vm_sg_name = "kc-sg"
  kc_vm_username = "admin"
  kc_vm_ssh_key_file = "~/.ssh/id_rsa.pub"

  # KC FQDN --> kc1.mydom.net
  dns_zone_name = "mydom-net"
  
  kc_ver = "20.0.2"
  kc_port = "8443"
  kc_adm_user = "admin"
  kc_adm_pass = "Fr#dR3n48Ga-Mov"

  # =================
  # PostgreSQL values
  # =================
  pg_db_ver = "15"
  pg_db_name = "kc1-db"
  pg_db_user = "dbadmin"
  pg_db_pass = "My82Sup@paS98"

  # ===================
  # Certificates values
  # ===================
  kc_cert_path = "/usr/local/etc/certs"
  le_cert_name = "kc1"
  le_cert_descr = "LE Certificate for Keycloak VM"
  le_cert_pub_chain = "cert-pub-chain.pem"
  le_cert_priv_key = "cert-priv-key.pem"
}

output "kc_fqdn" {
  value = "${module.keycloak-deploy.kc_fqdn}"
}
