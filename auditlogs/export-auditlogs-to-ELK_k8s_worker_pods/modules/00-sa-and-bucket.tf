# Create resource for timer
resource "null_resource" "previous" {}

# Create timer
resource "time_sleep" "wait_timer" {
  depends_on      = [null_resource.previous]
  create_duration = var.timer_for_mq
}

# Create SA for read/write bucket
resource "yandex_iam_service_account" "sa-writer" {
  folder_id = var.folder_id
  name      = var.service_account_id
}

# Grant permissions send logs to bucket
resource "yandex_resourcemanager_folder_iam_member" "upload_logs" {
  depends_on = [yandex_iam_service_account.sa-writer]
  folder_id  = var.folder_id
  role       = "storage.admin"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer.id}"
}

# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-writer-keys" {
  depends_on         = [yandex_iam_service_account.sa-writer]
  service_account_id = yandex_iam_service_account.sa-writer.id
  description        = "Static access/secret keys for SA"
}

# Create Auth Access Key for Service Account to get IAM Token
resource "yandex_iam_service_account_key" "sa-auth-key" {
  depends_on         = [yandex_iam_service_account.sa-writer]
  service_account_id = yandex_iam_service_account.sa-writer.id
  description        = "key for service account"
  key_algorithm      = "RSA_4096"
}

# Create backet
resource "yandex_storage_bucket" "es-bucket" {
  depends_on = [yandex_resourcemanager_folder_iam_member.upload_logs]
  access_key = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
  bucket     = var.log_bucket_name

  grant {
    id          = yandex_iam_service_account.sa-writer.id
    type        = "CanonicalUser"
    permissions = ["READ", "WRITE"]
  }

  # Remove backups after
  lifecycle_rule {
    id      = "allIndicies"
    enabled = var.s3_expiration["enabled"]
    expiration {
      days = var.s3_expiration["days"]
    }
  }

  versioning {
    enabled = false
  }
}
