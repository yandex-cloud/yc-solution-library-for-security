variable "vpc_name" {
  description = "VPC Name"
  type = string
}

variable "net_cidr" {
  description = "Subnet structure primitive"
  type = list(object({
    name = string,
    zone = string,
    prefix = string
  }))

  validation {
    condition = length(var.net_cidr) >= 1
    error_message = "At least one Subnet/Zone should be used."
  }
}

variable "zone" {
  type    = string
}

variable "nat" {
  type    = bool
  default = true
}

variable "image_family" {
  type    = string
}

variable "platform_id" {
  type    = string
}

variable "keycloak_name" {
  type    = string
}

variable "cores" {
  type    = number
}

variable "memory" {
  type    = number
}

variable "disk_size" {
  type    = number
}

variable "disk_type" {
  type    = string
}

variable "timeout_create" {
  default = "10m"
}

variable "timeout_delete" {
  default = "10m"
}

#-----------------------------------------

variable "domain_fqdn" {
  type    = string
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
}

variable "kms_key_name" {
  type = string
}

variable "sa_name" {
  type = string
}