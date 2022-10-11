variable "folder_id" {
  description = "ID of the folder to attach a policy to."
  type        = string
}
variable "name" {
  description = "Name of the network load balancer. Provided by the client when the network load balancer is created."
  type        = string
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
variable "roles" {
  description = "The roles that should be assigned"
  type        = list(string)
}
variable "cloud_id" {
  description = "The ID of the cloud to apply any resources to"
  type        = string
}
