resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = var.service_account_id
  description        = "static access key for object storage and s3 "
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/sync.zip"
}

resource "random_string" "project_suffix" {
  length  = 10
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "yandex_message_queue" "log_queue_for_auditlog" {
  count                       = var.auditlog_enabled ? 1 : 0 
  access_key                  = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  secret_key                  = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  name                        = "log-queue-auditlog-${random_string.project_suffix.result}"
  visibility_timeout_seconds  = 600
  receive_wait_time_seconds   = 20
  message_retention_seconds   = 1209600
}

resource "yandex_function" "s3_ymq_for_auditlog" {
  depends_on        = [yandex_message_queue.log_queue_for_auditlog]
  folder_id         = var.folder_id
  name              = "s3-ymq-auditlog-sync-${random_string.project_suffix.result}"
  runtime           = "python38"
  entrypoint        = "main.handler"
  memory            = "256"
  execution_timeout = "30"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_auditlog[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa_static_key.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
    AUDIT_LOG_PREFIX      = var.auditlogs_prefix
  }

  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_auditlog_trigger" {
  depends_on  = [yandex_message_queue.log_queue_for_auditlog,yandex_function.s3_ymq_for_auditlog]
  folder_id   = var.folder_id
  name        = "s3-ymq-auditlog-trigger-${random_string.project_suffix.result}"
  
  function {
    id = yandex_function.s3_ymq_for_auditlog.id 
    service_account_id = var.service_account_id
  }

  object_storage {
    bucket_id = var.log_bucket_name
    prefix    = var.auditlogs_prefix
    create    = true
    update    = false
    delete    = false
  }
}

resource "yandex_message_queue" "log_queue_for_falco" {
  count                       = var.falco_enabled ? 1 :0 
  access_key                  = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  secret_key                  = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  name                        = "log-queue-falco-${random_string.project_suffix.result}"
  visibility_timeout_seconds  = 600
  receive_wait_time_seconds   = 20
  message_retention_seconds   = 1209600
}

resource "yandex_function" "s3_ymq_for_falco" {
  depends_on        = [yandex_message_queue.log_queue_for_falco]
  folder_id         = var.folder_id
  name              = "s3-ymq-falco-sync-${random_string.project_suffix.result}"
  runtime           = "python38"
  entrypoint        = "main.handler"
  memory            = "256"
  execution_timeout = "30"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_falco[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa_static_key.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
    FALCO_LOG_PREFIX      = var.falco_prefix
  }
  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_falco_trigger" {
  depends_on  = [yandex_message_queue.log_queue_for_falco,yandex_function.s3_ymq_for_falco]
  folder_id   = var.folder_id
  name        = "s3-ymq-falco-trigger-${random_string.project_suffix.result}"
  
  function {
    id = yandex_function.s3_ymq_for_falco.id 
    service_account_id = var.service_account_id
  }

  object_storage {
    bucket_id = var.log_bucket_name
    prefix    = var.falco_prefix
    create    = true
    update    = false
    delete    = false
  }
}