variable "public_key_path" {
  description = "Path to public key file"
  default = "~/.ssh/id_rsa.pub"
}


variable "zone" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = "ru-central1-a"
}

variable "folder_id" {
}



variable "yandex_subnet_range" {
  default     = "10.10.0.0/24"
}

variable "k8s_version" {
  description = " Mk8s kubernetes version"
  default     = "1.18"
}


variable "cluster_sa_id" {
  description = "id of cluster_sa"
  default     = ""
}

variable "nodes_sa_id" {
  description = "id of nodes_sa"
  default     = ""
}

