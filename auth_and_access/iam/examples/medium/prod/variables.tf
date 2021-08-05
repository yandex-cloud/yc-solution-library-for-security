variable "network_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "network_description" {
  description = "An optional description of this resource. Provide this property when you create the resource."
  type        = string
  default     = "terraform-created"
}

variable "env" {
  default     = "demo"
  description = "Prefix of different environments where the resources will be created"
}

variable "folder_id" {
  type        = string
  description = "Folder-ID where the resources will be created"
}

variable "subnets" {
  description = "An optional description of this resource. Provide this property when you create the resource."
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

variable "k8s_version" {
  type        = string
  default     = "1.17"
  description = "Version for Kubernetes Cluster"
}
variable "release_channel" {
  type        = string
  default     = "REGULAR"
  description = "Release channel for Kubernetes Cluster"
}

variable "k8s_service_ipv4_range" {
  type        = string
  default     = "10.150.0.0/16"
  description = "CIDR for k8s services"
}

variable "k8s_pod_ipv4_range" {
  type        = string
  default     = "10.140.0.0/16"
  description = "CIDR for pods in k8s cluster"
}


