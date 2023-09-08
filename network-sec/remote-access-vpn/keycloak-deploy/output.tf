output "kc_admin_password" {
    value = random_string.keycloak_admin_password.result
}