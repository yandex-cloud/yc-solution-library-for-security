
#Give sa-web-app-tf permission on cloud

data "yandex_resourcemanager_cloud" "web-app" {
  cloud_id = var.CLOUD_ID
}

data "yandex_iam_service_account" "sa-web-app-tf" {
  name = "sa-web-app-tf"
  folder_id = var.FOLDER_ID
}


resource "yandex_resourcemanager_cloud_iam_member" "compute-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "compute.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "vpc-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "vpc.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "dns-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "dns.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "mdb-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "mdb.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "storageadmin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "storage.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "viewer" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "viewer"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "serviceAccounts-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "editor" # soon will be alter on "iam.editor"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}


#create sa-app and it binding (prod and non-prod)
#prod

data "yandex_resourcemanager_folder" "prod-folder" {
  name = "prod"
}
data "yandex_resourcemanager_folder" "nonprod-folder" {
  name = "nonprod"
}

resource "yandex_iam_service_account" "sa-app-prod" {
  name        = "sa-app-prod"
  folder_id = data.yandex_resourcemanager_folder.prod-folder.id
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-prod-bind1" {
  folder_id = data.yandex_resourcemanager_folder.prod-folder.id
  role = "lockbox.payloadViewer"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-prod.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-prod-bind2" {
  folder_id = data.yandex_resourcemanager_folder.prod-folder.id
  role = "storage.uploader"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-prod.id}"
}

#non-prod
resource "yandex_iam_service_account" "sa-app-non-prod" {
  name        = "sa-app-non-prod"
  folder_id = data.yandex_resourcemanager_folder.prod-folder.id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-app-non-prod-bind1" {
  folder_id = data.yandex_resourcemanager_folder.nonprod-folder.id
  role = "lockbox.payloadViewer"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-non-prod.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-non-prod-bind2" {
  folder_id = data.yandex_resourcemanager_folder.nonprod-folder.id
  role = "storage.uploader"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-non-prod.id}"
}
