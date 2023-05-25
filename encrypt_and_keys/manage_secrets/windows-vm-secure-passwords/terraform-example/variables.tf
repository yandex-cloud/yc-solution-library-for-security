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

variable "image_id" {
  type    = string
}

variable "platform_id" {
  type    = string
}

variable "vm_name" {
  type    = string
}

variable "host_name" {
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

#-----------------------------------------

variable "secret_name" {
  type = string
}

variable "kms_key_name" {
  type = string
}

variable "sa_name" {
  type = string
}

variable "windows_admin" {
  type = string
}

variable "win_adm_pass" {
  type = string
}