module "settings" {
  source = "../settings"
}

module "firezone" {
  source    = "../firezone"
  values    = module.settings
}

module "keycloak-deploy" {
  source    = "../keycloak-deploy"
  values    = merge(module.settings, module.firezone.output)
}
