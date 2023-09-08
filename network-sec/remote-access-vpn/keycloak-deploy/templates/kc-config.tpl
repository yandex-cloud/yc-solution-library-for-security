variable "kc_admin_password" {
  description = "Keycloak admin user password"
  type        = string
  default     = "${KC_ADM_PASS}"
}