variable "sa_id" {

}

variable "target_group_id" {

}

variable "folder_id" {

}

variable "load_balancer_id" {

}

variable "vpc_id" {

}

variable "bucket_id" {

}

variable "access_key" {
}

variable "secret_key" {

}

variable "route_switcher_sa_roles" {
  default = ["vpc.privateAdmin", "serverless.functions.invoker", "storage.uploader","ymq.admin"]
}
variable "first_router_address" {

}

variable "first_az_rt" {

}
variable "first_az_subnet_list" {

}
variable "second_router_address" {

}
variable "second_az_rt" {

}
variable "second_az_subnet_list" {

}

