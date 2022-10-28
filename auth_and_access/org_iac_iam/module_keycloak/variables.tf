# ===============
# Input Variables
# ===============

variable "cloud_id" {
  description = "YC cloud-id"
  type = string
}


variable "folder_id" {
  description = "YC folder-id"
  type = string
  default = "b1g075j6vem2radjttgi"
}

variable "org_id" {
  description = "YC Organization ID"
  type = string
}

variable "vpc_net_name" {
  description = "VPC Network Name"
  type = string
  default = "default"  
}

variable "vm_name" {
  description = "VM Name"
  type = string
  default = "keycloak"  
}

variable "vm_pub_ip_name" {
  description = "Public static ip reservation name"
  type = string
  default = "kc"
}

variable "vm_subnet" {
  description = "Keycloak VM subnet name"
  type = string
  default = "default-ru-central1-a"
}

variable "kc_fqdn" {
  description = "Keycloak VM FQDN / DNS Name"
  type = string
  default = "kc.lavre.link"
}

variable "dns_zone_name" {
  description = "DNS zone name - not equal domain name! "
  type = string
  default = "lavre-link"
}

variable "kc_realm" {
  description = "Keycloak Realm name"
  type = string
  default = "labs"
}

variable "kc_ver" {
  description = "Keycloak version"
  type = string
  default = "18.0.0"
}

variable "kc_port" {
  description = "Keycloak HTTPS port listener"
  type = string
  default = "8443"
}

variable "kc_adm_user" {
  description = "Keycloak admin user name"
  type = string
  default = "admin"
}

variable "kc_adm_pass" {
  description = "Keycloak admin user password"
  type = string
  default = "Fru#n38Ga-Duw"
}

variable "kc_cert_path" {
  description = "SSL certificates path location at Keycloak VM"
  type = string
  default = "/usr/local/etc/certs"
}

variable "pg_db_name" {
  description = "PostgeSQL cluster and database name"
  type = string
  default = "keycloak"
}

variable "pg_db_user" {
  description = "PostgeSQL database user name"
  type = string
  default = "dbuser"
}

variable "pg_db_pass" {
  description = "PostgeSQL database user's password"
  type = string
  default = "My82Sup@paS98"
}

variable "le_cert_name" {
  description = "Let's Encrypt certificate name for YC Certificate Manager"
  type = string
  default = "kc-lab"
}

variable "le_cert_descr" {
  description = "Let's Encrypt certificate description for YC Certificate Manager"
  type = string
  default = "LE Certificate for Keycloak"
}

variable "le_cert_pub_key" {
  description = "Let's Encrypt certificate public key chain filename"
  type = string
  default = "cert-pub-chain.pem"
}

variable "le_cert_priv_key" {
  description = "Let's Encrypt certificate private key filename"
  type = string
  default = "cert-priv-key.pem"
}

variable "kc_user_file" {
  description = "Keycloak users file name"
  type = string
  default = "kc-users.lst"
}

variable "kc_user_count" {
  description = "Number of user accounts which will be created at Keycloak"
  type = string
  default = "3"
}

variable "kc_user_prefix" {
  description = "Prefix for the user names Keycloak accounts"
  type = string
  default = "user"
}


# ============
# Data Sources
# ============

# data "yandex_vpc_network" "vpc_net" {
#   name = var.vpc_net_name
# }

# data "yandex_vpc_subnet" "vm_subnet" {
#   name = var.vm_subnet
# }

data "yandex_compute_image" "vm_image" {
  family = "ubuntu-2004-lts"
}

data "yandex_dns_zone" "dns_zone" {
  name = var.dns_zone_name
  folder_id = var.folder_id
}
