variable "groups" {
  type        = any
  description = "Map with key=group and value=list with iam users"
}
variable "role_network_admin" {
  type        = list(any)
  description = "List of permissions/service roles for organization network admins"
}
variable "role_sec_ops" {
  type        = list(any)
  description = "List of permissions/service roles for organization security officers"
}
variable "role_dev_project_developer" {
  type        = list(any)
  description = "List of permissions/service roles for project_developers in DEV env"
}
variable "role_prod_project_developer" {
  type        = list(any)
  description = "List of permissions/service roles for project_developers in PROD env"
}
variable "org_id" {
  type        = string
  description = "ORGANIZATION-ID where where need to add permissions."
}
variable "dev_folder_id" {
  type        = string
  description = "DEV Folder-ID where need to add permissions."
}
variable "prod_folder_id" {
  type        = string
  description = "PROD Folder-ID where need to add permissions."
}
variable "cloud_id" {
  type        = string
  description = "Cloud-ID where where need to add permissions. "
}
