# Uncomment when you need it
# add sa-web-app-tf with organization-manager.viewer permissions to org level state
#data "yandex_iam_service_account" "sa-web-app-tf" {
#  name = "sa-web-app-tf"
#  folder_id = "b1gdgdgn1v8ssifhu3lq" # choose your network-folder id of cloud web-app-project
#}


#resource "yandex_organizationmanager_organization_iam_member" "editor" {
#  organization_id = var.ORG_ID
#  role            = "organization-manager.viewer"
#  member          = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
#}
