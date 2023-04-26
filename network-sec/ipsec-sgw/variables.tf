# =======================================
# IPsec Security Gateway (SGW) deployment
# Input variables
# =======================================

# =================
# Global parameters
# =================
variable "cloud_id" {
  description = "YC cloud-id. Taken from environment variable."
}

variable "folder_id" {
  description = "YC folder-id. Taken from environment variable."
}

variable "ipsec_policy" {
  description = "IPsec parameters for both sides"
  type = object(
    {
      policy_name  = string
      ike_proposal = string
      esp_proposal = string
      psk          = string
  })
  default = {
    policy_name  = null
    ike_proposal = null
    esp_proposal = null
    psk          = null
  }
}

# =================================
# Yandex Cloud side: strongSwan SGW
# =================================

variable "yc_sgw" {
  description = "YC IPsec SGW"
  type = object(
    {
      name            = string
      folder_name     = string
      image_folder_id = string
      image_name      = string
      zone            = string
      subnet          = string
      inside_ip       = string
      admin_name      = string
      admin_key_path  = string
  })
  default = {
    name            = null
    folder_name     = null
    image_folder_id = "standard-images"
    image_name      = null
    zone            = null
    subnet          = null
    inside_ip       = null
    admin_name      = null
    admin_key_path  = null
  }
}

variable "yc_subnets" {
  description = "YC IP subnet prefixes"
  type = object(
    {
      net_name             = string
      prefix_list          = list(string)
      rt_name              = string
      rt_internet_access   = bool
      force_subnets_update = bool
  })
  default = {
    net_name             = null
    prefix_list          = null
    rt_name              = null
    rt_internet_access   = false
    force_subnets_update = false
  }
}

# =================================
# Remote side: 3rd party IPsec SGW
# =================================
variable "remote_sgw" {
  description = "Remote IPsec Security Gateway (SGW)"
  type = object(
    {
      name       = string
      type       = string
      outside_ip = string
  })
  default = {
    name       = null
    type       = "unknown"
    outside_ip = null
  }
  validation {
    condition = contains([
      "unknown",
      "cisco-iosxe",
      "cisco-asa",
      "mikrotik-chr"
      ], lower(var.remote_sgw.type)
    )
    error_message = "Only few SGW types are supported. See variables.tf for details."
  }
}

variable "remote_subnets" {
  description = "Yandex Cloud Subnet prefixes list"
  type        = list(string)
  default     = null
}

variable "labels" {
  description = "A set of key/value label pairs to assign."
  type        = map(string)
  default     = null
}
