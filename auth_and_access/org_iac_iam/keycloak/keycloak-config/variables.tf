# =======================================
# Keycloak-config module. Input variables
# =======================================

variable "labels" {
  description = "A set of key/value label pairs to assign."
  type = map(string)
  default = null
}

# ========================
# Org/Federation variables
# ========================
variable "org_id" {
  description = "YC Organization ID"
  type = string
  default = null
}

variable "fed_name" {
  description = "YC Federation name"
  type = string
  default = null
}

variable "yc_cert" {
  description = "Yandex Cloud SSL certificate"
  type = string
  default = "yc-root.crt"
}

variable "kc_user" {
  description = "Keycloak test user account"
  type = map(string) # name & password
  default = {}
}

# =====================
# Keycloak VM variables
# =====================

variable "kc_fqdn" {
  description = "Keycloak public DNS FQDN"
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

variable "kc_realm_name" {
  description = "Keycloak Realm name"
  type = string
  default = null
}

variable "kc_realm_descr" {
  description = "Keycloak Realm description"
  type = string
  default = null
}
