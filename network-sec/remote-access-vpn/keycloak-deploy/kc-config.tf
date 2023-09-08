# ===================================================================
# Copy of KC configuration variables to the keycloak-config TF module
# =================================================================== 
locals {
  kc_config_vars = templatefile("${path.module}/templates/kc-config.tpl", {
    KC_ADM_PASS = random_string.keycloak_admin_password.result
  })
}

resource "local_file" "kc_config_values" {
  content  = local.kc_config_vars
  filename = "../keycloak-config/variables.tf"
}