### Name convertion
variable "usernames_to_ids" {
  description = "If true Usernames from IAM and Federation will be used as input variables 'iam_users_names' and 'fed_users_names'"
  type        = bool
  default     = true

}
variable "federation_id" {
  description = "Federation ID, mandatory for 'fed_users_names'"
  type        = string
  default     = null
}


###Folder
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
Group of IAM User-IDs and it's permissions in FOLDER, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both
### Example
#folder_user_role_mapping = [
  {
    job_title_name  = "devops"
    iam_users_names = ["name.surname", ]
    fed_users_names = ["name.surname@yantoso.ru", ]
    roles = ["iam.serviceAccounts.user", "k8s.editor", "k8s.cluster-api.cluster-admin", "container-registry.admin"]
  },
  {
    job_title_name  = "developers"
    users_with_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
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

### Cloud

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
Group of IAM User-IDs and it's permissions in CLOUD, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both
### Example
#cloud_user_role_mapping = [
  {
    job_title_name  = "devops"
    iam_users_names = ["name.surname", ]
    fed_users_names = ["name.surname@yantoso.ru", ]
    roles = ["editor", ]
  },
  {
    job_title_name  = "developers"
    users_with_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    iam_users_names = ["name.surname", ]
    roles = ["viewer","k8s.editor",]
  },
 ]
EOT 
}

### Organization-manager

variable "org_binding_authoritative" {
  type        = bool
  default     = false
  description = <<EOT
  "Authoritative. Sets the IAM policy for the ORGANIZATION and replaces any **existing** policy already attached. 
  If Authoritative = true : take roles from all objects in  variable "org_user_role_mapping" and make **unique** role as a new key of map with members"
EOT 
}
variable "org_id" {
  type        = string
  default     = null
  description = "ORGANIZATION-ID where where need to add permissions. Mandatory variable for ORGANIZATION, if omited default ORGANIZATION_ID will be used"
}
variable "org_user_role_mapping" {
  default     = []
  type        = any
  description = <<EOT
Group of IAM User-IDs and it's permissions in ORGANIZATION, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both
### Example
#org_user_role_mapping = [
  {
    job_title_name  = "admins"
    iam_users_names = ["name.surname", ]
    fed_users_names = ["name.surname@yantoso.ru", ]
    roles = ["admin",]
  },
  {
    job_title_name  = "network_admins"
    users_with_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    roles = ["vpc.admin",]
  },
 ]
EOT 
}


