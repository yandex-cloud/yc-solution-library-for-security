# =======================================
# Keycloak-deploy module. Input variables
# =======================================

variable "cloud_id" {
  description = "Cloud ID"
}

variable "labels" {
  description = "A set of key/value label pairs to assign."
  type = map(string)
  default = null
}

# =====================
# Keycloak VM variables
# =====================
variable "kc_image_folder_id" {
  description = "Keycloak VM base image location (folder-id)"
  type = string
  default = null
}

variable "kc_image_name" {
  description = "Keycloak VM base image name"
  type = string
  default = null
}

variable "kc_network_name" {
  description = "Keycloak VM network name"
  type = string
  default = null
}

variable "kc_subnet_name" {
  description = "Keycloak VM subnet name"
  type = string
  default = null
}

variable "kc_folder_name" {
  description = "Keycloak VM folder name"
  type = string
  default = null
}

variable "kc_zone_id" {
  description = "Keycloak zone-id for deployment"
  type = string
  default = null
}

variable "kc_hostname" {
  description = "Keycloak VM name & Hostname & Public DNS name"
  type = string
  default = null
}

variable "kc_vm_local_ip" {
  description = "Keycloak VM local IP address"
  type = string
  default = null
}

variable "kc_vm_sg_name" {
  description = "Keycloak VM Security Group name"
  type = string
  default = null
}

variable "kc_vm_username" {
  description = "Keycloak VM username"
  type = string
  default = "admin"
}

variable "kc_vm_ssh_key_file" {
  description = "SSH Public key path and filename"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_zone_name" {
  description = "Yandex Cloud DNS Zone Name"
  type = string
  default = null
}

variable "kc_fqdn" {
  description = "Keycloak public DNS FQDN"
  type = string
  default = null
}

variable "kc_ver" {
  description = "Keycloak version for deployment"
  type = string
  default = null
}

variable "kc_port" {
  description = "Keycloak HTTPS port listener"
  type = string
  default = null
}

variable "kc_adm_user" {
  description = "Keycloak admin user name"
  type = string
  default = null
}

variable "kc_adm_pass" {
  description = "Keycloak admin user password"
  type = string
  default = null
}

# =============================
# Keycloak PostgreSQL variables
# =============================
variable "pg_db_ver" {
  description = "PostgeSQL cluster version"
  type = string
  default = null
}

variable "pg_db_name" {
  description = "PostgeSQL cluster and database name"
  type = string
  default = null
}

variable "pg_db_user" {
  description = "PostgeSQL database user name"
  type = string
  default = null
}

variable "pg_db_pass" {
  description = "PostgeSQL database user password"
  type = string
  default = null
}
# =================================
# Keycloak LE Certificate variables
# =================================

variable "kc_cert_path" {
  description = "SSL certificates path location in the Keycloak VM"
  type = string
  default = null
}

variable "le_cert_name" {
  description = "Let's Encrypt certificate name (CM)"
  type = string
  default = null
}

variable "le_cert_descr" {
  description = "Let's Encrypt certificate description (CM)"
  type = string
  default = null
}

variable "le_cert_pub_chain" {
  description = "Let's Encrypt certificate public key chain filename"
  type = string
  default = null
}

variable "le_cert_priv_key" {
  description = "Let's Encrypt certificate private key filename"
  type = string
  default = null
}
