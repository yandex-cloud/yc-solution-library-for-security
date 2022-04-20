




variable "folder_id" {

}

variable "cluster_name" {

}

variable "log_bucket_service_account_id" {

}

variable "fakeeventgenerator_enabled" {
    default = true
}

variable "podSecurityStandard" {
    default = "restricted"
}

variable "validationFailureAction" {
    default = "audit"
}

variable "log_bucket_name" {

}

variable "function_service_account_id" {
    default = ""
}