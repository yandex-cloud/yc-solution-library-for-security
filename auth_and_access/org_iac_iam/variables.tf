variable "BA_ID" {
  description = "billing account id"
  type = string
  default = ""
}

variable "ORG_ID" {
  description = "organization id"
  type    = string
  default = ""
}

variable "KEYCLOAK" {
  description = "install keycloak or no"
  type    = string
  default = ""
}

variable "ORG_ADMIN_FOLDER_ID" {
  description = "folder_id of first folder in org cloud"
  type    = string
  default = ""
}

variable "ORG_ADMIN_CLOUD_ID" {
  description = "cloud_id of first cloud"
  type    = string
  default = ""
}

variable "DNS_ZONE_NAME" {
  description = "name of dns zone in yandex cloud, not dns name"
  type    = string
  default = ""
}

variable "KC_FQDN" {
  description = "dns name of keycloak"
  type    = string
  default = ""
}

variable "CLOUD-1-NAME" {
  description = "name of the first cloud"
  type    = string
  default = ""
}

variable "CLOUD-2-NAME" {
  description = "name of the second cloud"
  type    = string
  default = ""
}


