variable "user_group_mapping" {
  default     = []
  type        = any
  description = <<EOT
Group of IAM User-IDs
### Example
#user_group_mapping = 
  {
    devops = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    developers = ["userAccount:idxxxxxx3"]
  }
EOT 
}

variable "staging_folder_id" {
  default     = "null"
  type        = string
}

variable "prod_folder_id" {
  default     = "null"
  type        = string
}

