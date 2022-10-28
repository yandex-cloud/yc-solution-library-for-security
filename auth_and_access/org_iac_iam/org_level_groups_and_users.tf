#Create org groups
resource "yandex_organizationmanager_group" web-admin-group {
  name            = "cloud-${var.CLOUD-1-NAME}-group-admins"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" mobile-admin-group {
  name            = "cloud-${var.CLOUD-2-NAME}-group-admins"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" sec-admin-group {
  name            = "cloud-security-group-admins"
  organization_id = var.ORG_ID
}


#Add users
data "yandex_organizationmanager_saml_federation_user_account" user1 {
  federation_id = module.keycloak[0].federation_id
  name_id       = "user1"
}

data "yandex_organizationmanager_saml_federation_user_account" user2 {
  federation_id = module.keycloak[0].federation_id
  name_id       = "user2"
}

data "yandex_organizationmanager_saml_federation_user_account" user3 {
  federation_id = module.keycloak[0].federation_id
  name_id       = "user3"
}

#Add users to org groups
resource "yandex_organizationmanager_group_membership" web-admin-group-members {
  group_id = yandex_organizationmanager_group.web-admin-group.id
  members  = [
    "${data.yandex_organizationmanager_saml_federation_user_account.user1.id}"
  ]
}

resource "yandex_organizationmanager_group_membership" mobile-admin-group-members {
  group_id = yandex_organizationmanager_group.mobile-admin-group.id
  members  = [
    "${data.yandex_organizationmanager_saml_federation_user_account.user2.id}"
  ]
}

resource "yandex_organizationmanager_group_membership" sec-admin-group-members {
  group_id = yandex_organizationmanager_group.sec-admin-group.id
  members  = [
    "${data.yandex_organizationmanager_saml_federation_user_account.user3.id}"
  ]
}

#Assign bindings on clouds to groups

resource "yandex_resourcemanager_cloud_iam_binding" "web-admin-binding" {
  cloud_id = yandex_resourcemanager_cloud.web-app-project.id
  role = "admin"
  members = [
    "group:${yandex_organizationmanager_group.web-admin-group.id}",
  ]
}

resource "yandex_resourcemanager_cloud_iam_binding" "mobile-admin-binding" {
  cloud_id = yandex_resourcemanager_cloud.mobile-app-project.id
  role = "admin"
  members = [
    "group:${yandex_organizationmanager_group.mobile-admin-group.id}",
  ]
}

resource "yandex_resourcemanager_cloud_iam_binding" "sec-admin-binding" {
  cloud_id = yandex_resourcemanager_cloud.sec-cloud.id
  role = "admin"
  members = [
    "group:${yandex_organizationmanager_group.sec-admin-group.id}",
  ]
}


# Create cloud groups

#Network folder groups------------------------------------------------------------
resource "yandex_organizationmanager_group" cloud-web-app-project-group-network-viewer {
  name            = "cloud-${var.CLOUD-1-NAME}-group-network-viewer"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-gitlab-admin {
  name            = "cloud-${var.CLOUD-1-NAME}-group-gitlab-admin"
  organization_id = var.ORG_ID
}

#Prod groups---------------------------------------------------------------------
resource "yandex_organizationmanager_group" cloud-web-app-project-group-prod-devops {
  name            = "cloud-${var.CLOUD-1-NAME}-group-prod-devops"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-prod-sre {
  name            = "cloud-${var.CLOUD-1-NAME}-group-prod-sre"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-prod-sa-app {
  name            = "cloud-${var.CLOUD-1-NAME}-group-prod-sa-app"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-prod-dba {
  name            = "cloud-${var.CLOUD-1-NAME}-group-prod-dba"
  organization_id = var.ORG_ID
}

# Non-prod groups---------------------------------------------------------------------
resource "yandex_organizationmanager_group" cloud-web-app-project-group-non-prod-devops {
  name            = "cloud-${var.CLOUD-1-NAME}-group-non-prod-devops"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-non-prod-sre {
  name            = "cloud-${var.CLOUD-1-NAME}-group-non-prod-sre"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-non-prod-sa-app {
  name            = "cloud-${var.CLOUD-1-NAME}-group-non-prod-sa-app"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-non-prod-dba {
  name            = "cloud-${var.CLOUD-1-NAME}-group-non-prod-dba"
  organization_id = var.ORG_ID
}



#Dev groups---------------------------------------------------------------------
resource "yandex_organizationmanager_group" cloud-web-app-project-group-dev-network-ad {
  name            = "cloud-${var.CLOUD-1-NAME}-group-dev-network-ad"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" cloud-web-app-project-group-dev-devops {
  name            = "cloud-${var.CLOUD-1-NAME}-group-dev-devops"
  organization_id = var.ORG_ID
}

#add to all group for related clouds
resource "yandex_resourcemanager_cloud_iam_binding" "view-at-cloud-level" {
  cloud_id = yandex_resourcemanager_cloud.web-app-project.id
  role = "resource-manager.viewer"
  members = [
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-network-viewer.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-gitlab-admin.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-prod-devops.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-prod-sre.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-prod-sa-app.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-prod-dba.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-devops.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-sre.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-sa-app.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-dba.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-dev-network-ad.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-dev-devops.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-dba.id}",
    "group:${yandex_organizationmanager_group.cloud-web-app-project-group-non-prod-dba.id}",
  ]
}

#Add users to cloud groups----------


# resource "yandex_organizationmanager_group_membership" network-viewer-group-members {
#   group_id = yandex_organizationmanager_group.cloud-web-app-project-group-network-viewer.id
#   members  = [
#     "${data.yandex_organizationmanager_saml_federation_user_account.user2.id}"
#   ]
# }

