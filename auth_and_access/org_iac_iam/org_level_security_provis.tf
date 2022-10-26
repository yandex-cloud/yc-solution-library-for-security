#Create folder
resource "yandex_resourcemanager_folder" "cloud_admin" {
  cloud_id = yandex_resourcemanager_cloud.sec-cloud.id
  name = "cloud-admin"
}

#Create sa
resource "yandex_iam_service_account" "sec-sa-trail" {
  name        = "sa-trails-admin"
  folder_id = yandex_resourcemanager_folder.cloud_admin.id
}

# Bind sa audit trails roles
resource "yandex_organizationmanager_organization_iam_member" "trails-bind-sa" {
  organization_id = var.ORG_ID
  role     = "audit-trails.admin"
  member   = "serviceAccount:${yandex_iam_service_account.sec-sa-trail.id}"
}
