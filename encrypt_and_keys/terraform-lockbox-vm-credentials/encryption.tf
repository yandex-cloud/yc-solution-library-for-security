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

# Creating symmetric KMS Key
resource "yandex_kms_symmetric_key" "kc-key" {
  name              = "${var.kms_key_name}"
  description       = "description for key"
  default_algorithm = "AES_256"
}

# SA role binding for KMS Key
resource "yandex_kms_symmetric_key_iam_binding" "encrypterDecrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.kc-key.id
  role             = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.kc-sa.id}",
  ]
}

# Creating Lockbox secrets via local exec because there are no terraform resources
# yc cli required!

resource "null_resource" "lockbox_secrets" {
  provisioner "local-exec" {
  command     = <<-CMD
    yc lockbox secret create --name ${var.secret_name} \
      --kms-key-id ${yandex_kms_symmetric_key.kc-key.id} \
      --payload - \
      --labels "key_id=${self.id}" \
      --labels "service_account_id=${self.id}" \
    <<PAYLOAD
    [
      {"key": "${var.kc_adm_user}", "text_value": "${var.kc_adm_pass}"},
      {"key": "${var.pg_db_user}", "text_value": "${var.pg_db_pass}"}
    ]
    PAYLOAD

    yc lockbox secret add-access-binding --name ${var.secret_name} --role lockbox.payloadViewer --service-account-id ${yandex_iam_service_account.kc-sa.id}
    CMD
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-CMD
    yc lockbox secret delete kc-secrets
    CMD
  }
  depends_on = [
    yandex_kms_symmetric_key.kc-key,
    yandex_iam_service_account.kc-sa
  ]
}

#Create ssh key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "pt_key.pem"
  file_permission = "0600"
}
