variable "folder_id" {
  description = "folder_id where route switcher infra is located"
  type        = string

}

variable "first_router_subnet" {
  type        = string
  description = "Subnet_id where healthchecked interface of the first router is located"
}


variable "second_router_subnet" {
  type        = string
  description = "Subnet_id where healthchecked interface of the second router is located"
}



variable "first_router_address" {
  type        = string
  description = "Healthchecked IP address of the first router"

}
variable "second_router_address" {
  type        = string
  description = "Healthchecked IP address of the first router"
}



variable "router_check_port" {
  description = "Healthchecked tcp port address"
  type        = number
  default     = 443
}


variable "route_switcher_sa_roles" {
  description = "roles that are needed for route checker service account"
  type        = list(string)

  default = ["load-balancer.privateAdmin", "storage.editor", "ymq.admin", "viewer"]
}

