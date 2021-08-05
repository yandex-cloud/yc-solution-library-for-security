variable "network_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "network_description" {
  description = "An optional description of this resource. Provide this property when you create the resource."
  type        = string
  default     = "terraform-created"
}
variable "folder_id" {
  type        = string
  default     = null
  description = "Folder-ID where the resources will be created"
}

variable "subnets" {
  description = "Describe your subnets preferences"
  type = list(object({
    zone           = string
    v4_cidr_blocks = string
  }))
  default = [
    {
      zone           = "ru-central1-a"
      v4_cidr_blocks = "10.110.0.0/16"
    },
    {
      zone           = "ru-central1-b"
      v4_cidr_blocks = "10.120.0.0/16"
    },
    {
      zone           = "ru-central1-c"
      v4_cidr_blocks = "10.130.0.0/16"
    }
  ]
}

variable "labels" {
  description = "A set of key/value label pairs to assign."
  type        = map(string)
  default     = null
}
