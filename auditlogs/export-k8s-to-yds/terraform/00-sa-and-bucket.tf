
#random
resource "random_string" "random" {
  length              = 4
  special             = false
  upper               = false 
}



#------

# Create SA for read/write yds
resource "yandex_iam_service_account" "sa-writer-to-yds" {
  folder_id = var.folder_id
  name      = "sa-for-writing-k8s-for-export"
}

# Grant permissions send logs to bucket
resource "yandex_resourcemanager_folder_iam_member" "upload_logs" {
  depends_on = [yandex_iam_service_account.sa-writer-to-yds]
  folder_id  = var.folder_id
  role       = "yds.writer"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer-to-yds.id}"
}

# Grant permissions invoke
resource "yandex_resourcemanager_folder_iam_member" "upload_logs2" {
  depends_on = [yandex_iam_service_account.sa-writer-to-yds]
  folder_id  = var.folder_id
  role       = "serverless.functions.invoker"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer-to-yds.id}"
}

# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-writer-to-yds-keys" {
  depends_on         = [yandex_iam_service_account.sa-writer-to-yds]
  service_account_id = yandex_iam_service_account.sa-writer-to-yds.id
  description        = "Static access/secret keys for SA"
}
