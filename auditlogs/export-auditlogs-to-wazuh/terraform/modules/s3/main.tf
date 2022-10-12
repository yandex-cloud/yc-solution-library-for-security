resource "random_pet" "this" {
  length = 2
}

resource "yandex_iam_service_account" "this" {
  name        = "${var.name}-${format(var.count_format, var.count_offset)}-${random_pet.this.id}"
  description = "Service account to be used by Terraform"
}

resource "yandex_resourcemanager_folder_iam_binding" "this" {
  count     = length(var.roles)
  folder_id = var.folder_id
  role      = element(var.roles, count.index)
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}",
  ]
  depends_on = [
    yandex_iam_service_account.this,
  ]
}

resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = yandex_iam_service_account.this.id
  depends_on = [
    yandex_iam_service_account.this,
  ]
}
data "yandex_resourcemanager_cloud" "this" {
  cloud_id = var.cloud_id
}
resource "yandex_resourcemanager_cloud_iam_binding" "this" {
  count    = length(var.roles)
  cloud_id = data.yandex_resourcemanager_cloud.this.id
  role     = element(var.roles, count.index)
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}
resource "yandex_storage_bucket" "this" {
  access_key    = yandex_iam_service_account_static_access_key.this.access_key
  secret_key    = yandex_iam_service_account_static_access_key.this.secret_key
  bucket        = "${var.name}-${format(var.count_format, var.count_offset)}-${random_pet.this.id}"
  force_destroy = true
  grant {
    id          = yandex_iam_service_account.this.id
    type        = "CanonicalUser"
    permissions = ["READ", "WRITE"]
  }
  depends_on = [yandex_iam_service_account.this]
}
