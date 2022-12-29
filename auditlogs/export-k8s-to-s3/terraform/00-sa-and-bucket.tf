
#random
resource "random_string" "random" {
  length              = 4
  special             = false
  upper               = false 
}

# Create SA for creation bucket
resource "yandex_iam_service_account" "sa-writer" {
  folder_id = var.folder_id
  name      = "sa-for-k8s-export"
}

# Grant permissions send logs to bucket
resource "yandex_resourcemanager_folder_iam_member" "create_bucket" {
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


# Create bucket
resource "yandex_storage_bucket" "es-bucket" {
  depends_on = [yandex_resourcemanager_folder_iam_member.upload_logs]
  access_key = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
  bucket     = "${var.log_bucket_name}-${random_string.random.result}"
  grant {
  id          = yandex_iam_service_account.sa-writer-to-bucket.id
  type        = "CanonicalUser"
  permissions = ["READ", "WRITE"]
}
}
#------

# Create SA for read/write bucket
resource "yandex_iam_service_account" "sa-writer-to-bucket" {
  folder_id = var.folder_id
  name      = "sa-for-writing-k8s-for-export"
}

# Grant permissions send logs to bucket
resource "yandex_resourcemanager_folder_iam_member" "upload_logs" {
  depends_on = [yandex_iam_service_account.sa-writer-to-bucket]
  folder_id  = var.folder_id
  role       = "storage.uploader"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer-to-bucket.id}"
}

# Grant permissions send logs to bucket
resource "yandex_resourcemanager_folder_iam_member" "upload_logs2" {
  depends_on = [yandex_iam_service_account.sa-writer-to-bucket]
  folder_id  = var.folder_id
  role       = "serverless.functions.invoker"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer-to-bucket.id}"
}

# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-writer-to-bucket-keys" {
  depends_on         = [yandex_iam_service_account.sa-writer-to-bucket]
  service_account_id = yandex_iam_service_account.sa-writer-to-bucket.id
  description        = "Static access/secret keys for SA"
}
