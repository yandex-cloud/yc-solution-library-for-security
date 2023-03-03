# Various
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function.zip"
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Cloud Function
resource "yandex_function" "main" {
  depends_on         = [yandex_iam_service_account_static_access_key.sa-static-key]
  folder_id          = var.folder_id
  name               = "cloud-log-s3-${random_string.suffix.result}"
  runtime            = "python39"
  entrypoint         = "main.handler"
  memory             = "256"
  execution_timeout  = "60"
  service_account_id = yandex_iam_service_account.sa.id

  environment = {
    CLUSTER_ID     = var.cluster_id
    BUCKET_NAME    = var.storage_bucket_name
    AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }

  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

# Cloud trigger
resource "yandex_function_trigger" "cloud-log" {
  name           = "cloud-log-s3-${random_string.suffix.result}"
  description    = "cloud-log-s3-${random_string.suffix.result}"
  
  logging {
    resource_types = ["k8s.cluster"] # should be at least one, that's why it's here
    resource_ids = [var.cluster_id] # should be at least one, that's why it's here
    group_id     = var.logging_group_id
    levels       = ["INFO"] # should be specified, that's why it's here
    batch_cutoff = "30"
    batch_size   = "100"

  }

  function {
    id = yandex_function.main.id
    service_account_id = yandex_iam_service_account.sa-invoker.id
  }
}

# Create service account for bucket
resource "yandex_iam_service_account" "sa" {
  folder_id       = var.folder_id
  name            = "cloud-log-s3-${random_string.suffix.result}"
  description     = "cloud-log-s3-${random_string.suffix.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-log-reader" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.sa.id}"
  role            = "logging.reader"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-storage-editor" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.sa.id}"
  role            = "storage.editor"
}

# Create service account for function trigger
resource "yandex_iam_service_account" "sa-invoker" {
  folder_id       = var.folder_id
  name            = "cloud-log-s3-invoker-${random_string.suffix.result}"
  description     = "cloud-log-s3-invoker-${random_string.suffix.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-invoker" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.sa-invoker.id}"
  role            = "functions.functionInvoker"
}

# Static access key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "cloud-log-s3-${random_string.suffix.result} static key"
}