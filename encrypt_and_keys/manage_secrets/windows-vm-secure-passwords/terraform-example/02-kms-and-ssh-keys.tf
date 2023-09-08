# Creating symmetric KMS Key
resource "yandex_kms_symmetric_key" "win-key" {
  name              = "${var.kms_key_name}"
  description       = "description for key"
  default_algorithm = "AES_256"
}

# SA role binding for KMS Key described in service-account.tf
resource "yandex_kms_symmetric_key_iam_binding" "encrypterDecrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.win-key.id
  role             = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.win-sa.id}",
  ]
}