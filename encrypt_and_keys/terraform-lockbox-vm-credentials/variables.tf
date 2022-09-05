variable "vpc_name" {
  description = "VPC Name"
  type = string
  default = "kc-network"
}

variable "net_cidr" {
  description = "Subnet structure primitive"
  type = list(object({
    name = string,
    zone = string,
    prefix = string
  }))

  default = [
    { name = "kc-subnet-a", zone = "ru-central1-a", prefix = "10.160.1.0/24" },
    { name = "kc-subnet-b", zone = "ru-central1-b", prefix = "10.161.1.0/24" },
    { name = "kc-subnet-c", zone = "ru-central1-c", prefix = "10.162.1.0/24" },
  ]

  validation {
    condition = length(var.net_cidr) >= 1
    error_message = "At least one Subnet/Zone should be used."
  }
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "nat" {
  type    = bool
  default = true
}

variable "image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "image_id" {
  type    = string
  default = "fd8aic46uv4b9nc3pqt7"
}

variable "platform_id" {
  type    = string
  default = "standard-v3"
}

variable "keycloak_name" {
  type    = string
}

variable "ws_name" {
  type    = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4
}

variable "disk_size" {
  type    = number
  default = 50
}

variable "disk_type" {
  type    = string
  default = "network-nvme"
}

variable "timeout_create" {
  default = "10m"
}

variable "timeout_delete" {
  default = "10m"
}

#-----------------------------------------
variable "opencart_image_id" {
  type    = string
  default = "fd80od21rjl4r3enr4sk"
}

variable "domain_fqdn" {
  type    = string
}

variable "kc_realm" {
  description = "Keycloak Realm name"
  type = string
}

variable "kc_ver" {
  description = "Keycloak version"
  type = string
}

variable "kc_port" {
  description = "Keycloak HTTPS port listener"
  type = string
}

variable "kc_adm_user" {
  description = "Keycloak admin user name"
  type = string
}

variable "kc_adm_pass" {
  description = "Keycloak admin user password"
  type = string
}

variable "pg_db_name" {
  description = "PostgeSQL cluster and database name"
  type = string
  default = "kc-sql"
}

variable "pg_db_user" {
  description = "PostgeSQL database user name"
  type = string
}

variable "pg_db_pass" {
  description = "PostgeSQL database user's password"
  type = string
}

variable "secret_name" {
  type = string
  default = "kc-secrets"
}

variable "kms_key_name" {
  type = string
  default = "kc-key"
}

variable "sa_name" {
  type = string
  default = "kc-sa"
}

variable "CLOUDID" {
  type = string
}

variable "FOLDERID" {
  type = string
}