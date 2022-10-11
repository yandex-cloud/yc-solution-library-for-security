variable "folder_id" {
  description = "ID of the folder to attach a policy to."
  type        = string
}
variable "cloud_id" {
  description = "The ID of the cloud to apply any resources to"
  type        = string
}
variable "image_id" {
  description = "A disk image to initialize this disk from"
  type        = string
}
