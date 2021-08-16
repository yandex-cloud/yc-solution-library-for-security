data "archive_file" "worker" {
  type        = "zip"
  source_dir  = "${path.module}/worker"
  output_path = "${path.module}/worker.zip"
}

resource "yandex_function" "s3_ymq_for_auditlog_puller" {
  depends_on        = [yandex_message_queue.log_queue_for_auditlog]
  folder_id         = var.folder_id
  name              = "s3-ymq-auditlog-worker-${random_string.project_suffix.result}"
  runtime           = "python38"
  entrypoint        = "worker.handler"
  memory            = "256"
  execution_timeout = "60"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_auditlog[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa_static_key.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
    S3_BUCKET             = var.log_bucket_name
    ELASTIC_AUTH_PW       = var.elastic_pw
    ELASTIC_AUTH_USER     = var.elastic_user
    ELASTIC_SERVER        = var.elastic_server # "https://c-xxx.rw.mdb.yandexcloud.net"
    AUDIT_LOG_PREFIX      = var.auditlogs_prefix
  }

  user_hash = data.archive_file.worker.output_base64sha256
  content {
    zip_filename = data.archive_file.worker.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_for_auditlog_puller_trigger" {
  depends_on  = [yandex_message_queue.log_queue_for_auditlog,yandex_function.s3_ymq_for_auditlog_puller]
  folder_id   = var.folder_id
  name        = "s3-ymq-auditlog-puller-trigger-${random_string.project_suffix.result}"
  
  function {
    id = yandex_function.s3_ymq_for_auditlog_puller.id 
    service_account_id = var.service_account_id
  }

  timer {
    cron_expression = "0/2 * * * ? *"
  }
}

resource "yandex_function" "s3_ymq_for_falco_puller" {
  depends_on        = [yandex_message_queue.log_queue_for_falco]
  folder_id         = var.folder_id
  name              = "s3-ymq-falco-worker-${random_string.project_suffix.result}"
  runtime           = "python38"
  entrypoint        = "worker.handler"
  memory            = "256"
  execution_timeout = "60"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_falco[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa_static_key.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
    S3_BUCKET             = var.log_bucket_name
    ELASTIC_AUTH_PW       = var.elastic_pw
    ELASTIC_AUTH_USER     = var.elastic_user
    ELASTIC_SERVER        = var.elastic_server # "https://c-xxx.rw.mdb.yandexcloud.net"
    FALCO_LOG_PREFIX      = var.falco_prefix
  }

  user_hash = data.archive_file.worker.output_base64sha256
  content {
    zip_filename = data.archive_file.worker.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_for_falco_puller_trigger" {
  depends_on  = [yandex_message_queue.log_queue_for_falco,yandex_function.s3_ymq_for_falco_puller]
  folder_id   = var.folder_id
  name        = "s3-ymq-falco-puller-trigger-${random_string.project_suffix.result}"
  
  function {
    id = yandex_function.s3_ymq_for_falco_puller.id 
    service_account_id = var.service_account_id
  }

  timer {
    cron_expression = "0/2 * * * ? *"
  }
}