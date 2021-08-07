resource "yandex_iam_service_account" "log-writer-sa" {
  name        = "log-writer-sa"
  description = "service account to write logs to bucket"
}

resource "yandex_resourcemanager_folder_iam_binding" "s3bind" {
  folder_id = "${var.folder_id}"

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.log-writer-sa.id}",
  ]
}

resource "yandex_iam_service_account_static_access_key" "bastion-key" {
  service_account_id = yandex_iam_service_account.log-writer-sa.id
  description        = "static access key for object storage"
}

output "aws_key_id" {
  value = "${yandex_iam_service_account_static_access_key.bastion-key.access_key}"
}

output "aws_secret" {
  value = "${yandex_iam_service_account_static_access_key.bastion-key.secret_key}"
}

output "s3_writer" {
  value = "${yandex_iam_service_account.log-writer-sa.id}"
}
