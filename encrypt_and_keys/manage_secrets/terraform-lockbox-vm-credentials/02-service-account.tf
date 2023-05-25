# Creating Service Account
resource "yandex_iam_service_account" "kc-sa" {
  name        = "${var.sa_name}"
}

# Creating self admin binding for future self deletion
resource "yandex_iam_service_account_iam_binding" "sa-self-binding" {
  service_account_id = "${yandex_iam_service_account.kc-sa.id}"
  role               = "admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.kc-sa.id}",
  ]
}