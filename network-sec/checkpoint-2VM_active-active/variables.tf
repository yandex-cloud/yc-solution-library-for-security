//-------------For terrafrom
variable "cloud_id" {
  default     = "your cloud id" #yc config get cloud-id
}

//------------VPC List
//--VPC 1
variable "vpc_name_1" {
  default     = "servers" #choose your name for vpc-1
}

variable "subnet-a_vpc_1" {
  default = "10.160.1.0/24" #change if you need
}
variable "subnet-b_vpc_1" {
  default = "10.161.1.0/24" #change if you need
}
//--VPC 2
variable "vpc_name_2" {
  default     = "database" #choose your name for vpc-2
}

variable "subnet-a_vpc_2" {
  default = "10.160.2.0/24" #change if you need
}
variable "subnet-b_vpc_2" {
  default = "10.161.2.0/24" #change if you need
}
//--VPC 3
variable "vpc_name_3" {
  default     = "transit" #choose your name for vpc-transit
}

variable "subnet-a_vpc_3" {
  default = "172.16.1.0/24" #change if you need
}
variable "subnet-b_vpc_3" {
  default = "172.16.2.0/24" #change if you need
}
//--VPC 4
variable "vpc_name_4" {
  default     = "mgmt" #choose your name for mgmt
}

variable "subnet-a_vpc_4" {
  default = "192.168.1.0/24" #change if you need
}
variable "subnet-b_vpc_4" {
  default = "192.168.2.0/24" #change if you need
}
//-----------Fake VPC List (for the future because of limit "cant add interfaces after vm creation")

variable "vpc_name_5" {
  default     = "vpc5" #choose your name for vpc
}

variable "subnet-a_vpc_5" {
  default = "10.5.1.0/24" #change if you need
}
variable "subnet-b_vpc_5" {
  default = "10.5.2.0/24" #change if you need
}
//--
variable "vpc_name_6" {
  default     = "vpc6" #choose your name for vpc
}

variable "subnet-a_vpc_6" {
  default = "10.6.1.0/24" #change if you need
}
variable "subnet-b_vpc_6" {
  default = "10.6.2.0/24" #change if you need
}
//--
variable "vpc_name_7" {
  default     = "vpc7" #choose your name for vpc
}

variable "subnet-a_vpc_7" {
  default = "10.7.1.0/24" #change if you need
}
variable "subnet-b_vpc_7" {
  default = "10.7.2.0/24" #change if you need
}
//--
variable "vpc_name_8" {
  default     = "vpc8" #choose your name for vpc
}

variable "subnet-a_vpc_8" {
  default = "10.8.1.0/24" #change if you need
}
variable "subnet-b_vpc_8" {
  default = "10.8.2.0/24" #change if you need
}
//--