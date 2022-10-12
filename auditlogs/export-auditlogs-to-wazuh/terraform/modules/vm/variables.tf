variable "az" {
  default     = "ru-central1-a"
  description = "The availability zone where the virtual machine will be created. If it is not provided, the default provider folder is used."
  type        = string

}

variable "instance_count" {
  default     = 1
  description = "Vm(s) count"
  type        = string
}
variable "instance_name" {
  description = "Resource name"
  type        = string

}
variable "subnet_id" {
  description = "YID of the subnet to attach this interface to. The subnet must exist in the same zone where this instance will be created."
  type        = string
}

variable "instance_type" {
  default     = "standard-v1"
  description = "The type of virtual machine to create. The default is 'standard-v1'"
  type        = string
}

variable "cores" {
  default     = 2
  description = "CPU cores for the instance"
  type        = string
}
variable "core_fraction" {
  default     = 20
  description = "Specifies baseline performance for a core as a percent"
}
variable "memory" {
  default     = 2
  description = "Memory size in GB"
  type        = string
}
variable "boot_disk" {
  default     = "network-hdd"
  description = "Disk type"
  type        = string
}
variable "disk_size" {
  default     = 100
  description = "Size of the disk in GB."
  type        = string
  validation {
    condition     = var.disk_size >= 50
    error_message = "Disk size must be not less than 50Gb!"
  }

}

variable "count_offset" {
  default     = 0
  description = "Default count offset"
}
variable "count_format" {
  default     = "%01d"
  description = "Default count format"
  type        = string
}
variable "image_id" {
  description = "A disk image to initialize this disk from"
  type        = string
}
variable "use_nat" {
  default     = false
  description = "Provide a public address, for instance, to access the internet over NAT."
  type        = bool
}
variable "vm_metadata" {
  default     = {}
  description = "Metadata key/value pairs to make available from within the instance."
  type        = map(string)
}

variable "labels" {
  default     = {}
  description = "Labels for resources"
  type        = map(string)

}
variable "service_account_id" {
  default     = ""
  description = "ID of the service account authorized for this instance."
  type        = string
}
