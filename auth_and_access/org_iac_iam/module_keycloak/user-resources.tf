# ==================
# YC Users resources
# ==================

# resource "yandex_resourcemanager_cloud" "cloud" {
#   organization_id = "bpfou6cmuk9cse6vqu2j"
#   name = "cloud-003"
# }

data "yandex_organizationmanager_saml_federation_user_account" fed_user {
  count = length(local.users)
  federation_id = "${yandex_organizationmanager_saml_federation.federation.id}"
  name_id = local.users[count.index]
}

# resource "yandex_resourcemanager_cloud_iam_member" "cloud_member" {
#   count = length(local.users)
#   cloud_id = var.cloud_id
#   role = "resource-manager.clouds.member"
#   member = "federatedUser:${data.yandex_organizationmanager_saml_federation_user_account.fed_user[count.index].id}"

#   depends_on = [
#     yandex_organizationmanager_saml_federation.federation
#   ]
# }

# resource "yandex_resourcemanager_folder" "folder" {
#   count = length(local.users)
#   cloud_id = var.cloud_id
#   name = local.users[count.index]

#   depends_on = [
#     yandex_organizationmanager_saml_federation.federation
#   ]
# }

# resource "yandex_resourcemanager_folder_iam_member" "folder_admin" {
#   count = length(local.users)
#   folder_id = "${yandex_resourcemanager_folder.folder[count.index].id}"
#   role = "admin"
#   member = "federatedUser:${data.yandex_organizationmanager_saml_federation_user_account.fed_user[count.index].id}"

#   depends_on = [
#     yandex_organizationmanager_saml_federation.federation
#   ]
# }

locals {
  users = flatten([for s in split("\n",("${file("${path.module}/kc-users.lst")}")) : regex("(.*):",s) if s != ""])
}

/*
output "kc_users" {
  value = local.users
}
*/
