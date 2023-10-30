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
  depends_on         = [
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_lockbox_secret_iam_binding.sa-viewer
  ]
  folder_id          = var.folder_id
  name               = "cloud-log-s3-${random_string.suffix.result}"
  runtime            = "python39"
  entrypoint         = "main.handler"
  memory             = "256"
  execution_timeout  = "60"
  service_account_id = yandex_iam_service_account.sa.id

  environment = {
    BUCKET_NAME    = var.storage_bucket_name
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "access_key"
    environment_variable = "AWS_ACCESS_KEY_ID"
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "secret_key"
    environment_variable = "AWS_SECRET_ACCESS_KEY"
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
    group_id     = var.logging_group_id
    batch_cutoff = "30"
    batch_size   = "100"
    stream_names = ["audit"]
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

resource "yandex_resourcemanager_folder_iam_member" "sa-lockbox-payload" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.sa.id}"
  role            = "lockbox.payloadViewer"
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

# Lockbox
resource "yandex_lockbox_secret" "secret-aws" {
  name = "cloud-log-${random_string.suffix.result}"
}

resource "yandex_lockbox_secret_version" "secret-aws-v1" {
  secret_id = yandex_lockbox_secret.secret-aws.id
  entries {
    key        = "access_key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  }
  entries {
    key        = "secret_key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }
}

resource "yandex_lockbox_secret_iam_binding" "sa-viewer" {
  secret_id = yandex_lockbox_secret.secret-aws.id
  role             = "viewer"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}