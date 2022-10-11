variable "vpc_name" {
  description = "Yandex vpc name"
  type        = string
}

variable "vpc_subnets" {
  description = "Map of vpc zone with cidr"
  type = map(object({
    zone = string
    cidr = string
  }))
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
}
