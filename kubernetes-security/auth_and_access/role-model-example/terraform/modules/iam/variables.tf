
variable "folder_id" {
  default     = null
  type        = string
  description = "Folder-ID where need to add permissions. Mandatory variable for FOLDER, if omited default FOLDER_ID will be used"
}
variable "folder_binding_authoritative" {
  type        = bool
  default     = false
  description = "Authoritative. Sets the IAM policy for the FOLDER and replaces any **existing** policy already attached."
}

variable "folder_user_role_mapping" {
  default     = []
  type        = any
  description = <<EOT
Group of IAM User-IDs and it's permissions in FOLDER, where name = JOB Tille
### Example
#folder_user_role_mapping = [
  {
    name  = "devops"
    users = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    roles = ["iam.serviceAccounts.user", "k8s.editor", "k8s.cluster-api.cluster-admin", "container-registry.admin"]
  },
  {
    name  = "developers"
    users = ["userAccount:idxxxxxx3"]
    roles = ["k8s.viewer",]
  },
]
EOT 
}

variable "sa_role_mapping" {
  default     = []
  type        = any
  description = <<EOT
  List of SA and it's permissions
### Example
sa_role_mapping = [
  {
    name  = "sa-cluster"
    roles = ["editor",]
  },
    {
    name  = "sa-nodes"
    roles = ["container-registry.images.puller",]
  },
]
EOT
}

variable "cloud_binding_authoritative" {
  type        = bool
  default     = false
  description = <<EOT
  "Authoritative. Sets the IAM policy for the CLOUD and replaces any **existing** policy already attached. 
  If Authoritative = true : take roles from all objects in  variable "cloud_user_role_mapping" and make **unique** role as a new key of map with members"
EOT 
}
variable "cloud_id" {
  type        = string
  default     = null
  description = "Cloud-ID where where need to add permissions. Mandatory variable for CLOUD, if omited default CLOUD_ID will be used"
}

variable "cloud_user_role_mapping" {
  default     = []
  type        = any
  description = <<EOT
Group of IAM User-IDs and it's permissions in CLOUD, where name = JOB Tille
### Example
#cloud_user_role_mapping = [
  {
    name  = "devops"
    users = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    roles = ["editor", ]
  },
  {
    name  = "developers"
    users = ["userAccount:idxxxxxx3"]
    roles = ["viewer","k8s.editor",]
  },
 ]
EOT 
}
