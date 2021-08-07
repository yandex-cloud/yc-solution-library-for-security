resource "yandex_iam_service_account" "ig_sa" {
  name        = "ig-sa"
  description = "service account to manage ig"
}


resource "yandex_resourcemanager_folder_iam_binding" "sabind" {
  folder_id = "${var.folder_id}"

  role = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.ig_sa.id}",
  ]
}
