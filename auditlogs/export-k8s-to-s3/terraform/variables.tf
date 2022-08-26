# Variables for Import

# Initial variables
variable "folder_id" {
  description = "The Yandex.Cloud folder id."
  type        = string
}

variable "cloud_id" {
  description = "The Yandex.Cloud cloud id."
  type        = string
}

variable "region_name" {
  description = "The Yandex.Cloud Cloud Region name."
  type        = string
  default     = "ru-central1"
}

variable "cluster_name" {
  description = "The Yandex.Cloud K8s cluster name."
  type        = string
}

# S3 Bucket Variables
variable "log_bucket_name" {
  type = string
}



