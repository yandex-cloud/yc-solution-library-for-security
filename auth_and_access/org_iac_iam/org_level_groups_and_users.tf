#Create org groups

resource "yandex_organizationmanager_group" cloud-admins-group {
  count = length(var.CLOUD-LIST)
  name = "${var.CLOUD-LIST[count.index].name}-cloud-admins"
  organization_id = var.ORG_ID
}



#Add users

data "yandex_organizationmanager_saml_federation_user_account" user {
  count = length(var.CLOUD-LIST)
  federation_id = module.keycloak[0].federation_id
  name_id       = var.CLOUD-LIST[count.index].admin
}



resource "yandex_organizationmanager_group_membership" admin-group-members {
  count = length(var.CLOUD-LIST)
  group_id = yandex_organizationmanager_group.cloud-admins-group[count.index].id
  members  = [
    "${data.yandex_organizationmanager_saml_federation_user_account.user[count.index].id}"
  ]
}

#Assign bindings on clouds to groups



resource "yandex_resourcemanager_cloud_iam_member" "admin-binding" {
  count = length(var.CLOUD-LIST)
  cloud_id = yandex_resourcemanager_cloud.create-clouds[count.index].id
  role     = "admin"
  member   = "group:${yandex_organizationmanager_group.cloud-admins-group[count.index].id}"
}


# Create cloud groups

#Network folder groups------------------------------------------------------------


resource "yandex_organizationmanager_group" network-folder-groups-cloud1 {
  count = length(var.NETWORK-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[0].name}-${var.NETWORK-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" network-folder-groups-cloud2 {
  count = length(var.NETWORK-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[1].name}-${var.NETWORK-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}


#Prod groups---------------------------------------------------------------------


resource "yandex_organizationmanager_group" prod-folder-groups-cloud1 {
  count = length(var.PROD-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[0].name}-${var.PROD-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" prod-folder-groups-cloud2 {
  count = length(var.PROD-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[1].name}-${var.PROD-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

# Non-prod groups---------------------------------------------------------------------


resource "yandex_organizationmanager_group" nonprod-folder-groups-cloud1 {
  count = length(var.NONPROD-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[0].name}-${var.NONPROD-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" nonprod-folder-groups-cloud2 {
  count = length(var.NONPROD-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[1].name}-${var.NONPROD-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

#Dev groups---------------------------------------------------------------------


resource "yandex_organizationmanager_group" dev-folder-groups-cloud1 {
  count = length(var.DEV-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[0].name}-${var.DEV-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

resource "yandex_organizationmanager_group" dev-folder-groups-cloud2 {
  count = length(var.DEV-CLOUD_GROUPS)
  name = "${yandex_resourcemanager_cloud.create-clouds[1].name}-${var.DEV-CLOUD_GROUPS[count.index].name}"
  organization_id = var.ORG_ID
}

#add to all group for related clouds

resource "yandex_resourcemanager_cloud_iam_member" "cloud-viewer" {
  count = length(yandex_resourcemanager_cloud.create-clouds)
  cloud_id = yandex_resourcemanager_cloud.create-clouds[count.index].id
  role     = "resource-manager.viewer"
  member   = "group:${yandex_organizationmanager_group.cloud-admins-group[count.index].id}"
}






#Add users to cloud groups----------


# data "yandex_organizationmanager_saml_federation_user_account" user1 {
#   federation_id = module.keycloak[0].federation_id
#   name_id       = "user1@example.com"
# }

# resource "yandex_organizationmanager_group_membership" network-viewer-group-members {
#   group_id = yandex_organizationmanager_group.network-folder-groups-cloud1[0].id
#   members  = [
#     "${data.yandex_organizationmanager_saml_federation_user_account.user1.id}"
#   ]
# }

 