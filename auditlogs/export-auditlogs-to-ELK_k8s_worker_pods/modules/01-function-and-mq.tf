data "archive_file" "function_pusher" {
  type        = "zip"
  source_dir  = "${path.module}/pusher"
  output_path = "${path.module}/pusher.zip"
}

resource "random_string" "project_suffix" {
  length  = 10
  upper   = false
  lower   = true
  number  = true
  special = false
}

#--------Permissions-----------
# Grant permissions to create function_pusher
resource "yandex_resourcemanager_folder_iam_binding" "create_funct" {
  depends_on = [yandex_iam_service_account.sa-writer]
  folder_id  = var.folder_id
  role       = "serverless.functions.admin"
  members    = ["serviceAccount:${yandex_iam_service_account.sa-writer.id}"]
}

# Grant permissions send logs to queue
resource "yandex_resourcemanager_folder_iam_member" "send_queue" {
  depends_on = [yandex_iam_service_account.sa-writer]
  folder_id  = var.folder_id
  role       = "ymq.admin"
  member     = "serviceAccount:${yandex_iam_service_account.sa-writer.id}"
}

#--------AUDIT-----------
resource "yandex_message_queue" "log_queue_for_auditlog" {
  count                      = var.auditlog_enabled ? 1 : 0
  depends_on                 = [time_sleep.wait_timer, yandex_resourcemanager_folder_iam_member.send_queue]
  access_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
  secret_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
  name                       = "log-queue-auditlog-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  visibility_timeout_seconds = 600
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 1209600
}

resource "yandex_function" "s3_ymq_for_auditlog" {
  depends_on        = [yandex_resourcemanager_folder_iam_binding.create_funct, yandex_message_queue.log_queue_for_auditlog]
  folder_id         = var.folder_id
  name              = "s3-ymq-auditlog-sync-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  runtime           = "python38"
  entrypoint        = "main.handler"
  memory            = "256"
  execution_timeout = "30"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_auditlog[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
    AUDIT_LOG_PREFIX      = var.auditlogs_prefix
    CLOUD_ID              = data.yandex_resourcemanager_folder.my_folder.cloud_id
    CLUSTER_ID            = data.yandex_kubernetes_cluster.my_cluster.id
    FOLDER_ID             = var.folder_id
  }

  user_hash = data.archive_file.function_pusher.output_base64sha256
  content {
    zip_filename = data.archive_file.function_pusher.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_auditlog_trigger" {
  depends_on = [yandex_message_queue.log_queue_for_auditlog, yandex_function.s3_ymq_for_auditlog]
  folder_id  = var.folder_id
  name       = "s3-ymq-auditlog-trigger-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"

  function {
    id                 = yandex_function.s3_ymq_for_auditlog.id
    service_account_id = yandex_iam_service_account.sa-writer.id
  }

  object_storage {
    bucket_id = var.log_bucket_name
    prefix    = var.auditlogs_prefix
    create    = true
    update    = false
    delete    = false
  }
}

#--------FALCO-----------
resource "yandex_message_queue" "log_queue_for_falco" {
  count                      = var.falco_enabled ? 1 : 0
  depends_on                 = [time_sleep.wait_timer, yandex_resourcemanager_folder_iam_member.send_queue]
  access_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
  secret_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
  name                       = "log-queue-falco-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  visibility_timeout_seconds = 600
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 1209600
}

resource "yandex_function" "s3_ymq_for_falco" {
  depends_on        = [yandex_resourcemanager_folder_iam_binding.create_funct, yandex_message_queue.log_queue_for_auditlog]
  folder_id         = var.folder_id
  name              = "s3-ymq-falco-sync-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  runtime           = "python38"
  entrypoint        = "main.handler"
  memory            = "256"
  execution_timeout = "30"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_falco[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
    FALCO_LOG_PREFIX      = var.falco_prefix
    CLOUD_ID              = data.yandex_resourcemanager_folder.my_folder.cloud_id
    CLUSTER_ID            = data.yandex_kubernetes_cluster.my_cluster.id
    FOLDER_ID             = var.folder_id
  }
  user_hash = data.archive_file.function_pusher.output_base64sha256
  content {
    zip_filename = data.archive_file.function_pusher.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_falco_trigger" {
  depends_on = [yandex_message_queue.log_queue_for_falco, yandex_function.s3_ymq_for_falco]
  folder_id  = var.folder_id
  name       = "s3-ymq-falco-trigger-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"

  function {
    id                 = yandex_function.s3_ymq_for_falco.id
    service_account_id = yandex_iam_service_account.sa-writer.id
  }

  object_storage {
    bucket_id = var.log_bucket_name
    prefix    = var.falco_prefix
    create    = true
    update    = false
    delete    = false
  }
}

#--------KYVERNO-----------
resource "yandex_message_queue" "log_queue_for_kyverno" {
  count                      = var.kyverno_enabled ? 1 : 0
  depends_on                 = [time_sleep.wait_timer, yandex_resourcemanager_folder_iam_member.send_queue]
  access_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
  secret_key                 = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
  name                       = "log-queue-kyverno-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  visibility_timeout_seconds = 600
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 1209600
}

resource "yandex_function" "s3_ymq_for_kyverno" {
  depends_on        = [yandex_resourcemanager_folder_iam_binding.create_funct, yandex_message_queue.log_queue_for_auditlog]
  count             = var.kyverno_enabled ? 1 : 0
  folder_id         = var.folder_id
  name              = "s3-ymq-kyverno-sync-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"
  runtime           = "python38"
  entrypoint        = "main.handler"
  memory            = "256"
  execution_timeout = "30"

  environment = {
    YMQ_URL               = yandex_message_queue.log_queue_for_kyverno[0].id
    AWS_ACCESS_KEY_ID     = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
    AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
    KYVERNO_LOG_PREFIX    = var.kyverno_prefix
    CLOUD_ID              = data.yandex_resourcemanager_folder.my_folder.cloud_id
    CLUSTER_ID            = data.yandex_kubernetes_cluster.my_cluster.id
    FOLDER_ID             = var.folder_id
  }
  user_hash = data.archive_file.function_pusher.output_base64sha256
  content {
    zip_filename = data.archive_file.function_pusher.output_path
  }
}

resource "yandex_function_trigger" "s3_ymq_kyverno_trigger" {
  depends_on = [yandex_message_queue.log_queue_for_kyverno, yandex_function.s3_ymq_for_kyverno]
  count      = var.kyverno_enabled ? 1 : 0
  folder_id  = var.folder_id
  name       = "s3-ymq-kyverno-trigger-${random_string.project_suffix.result}-${data.yandex_kubernetes_cluster.my_cluster.name}"

  function {
    id                 = yandex_function.s3_ymq_for_kyverno[0].id
    service_account_id = yandex_iam_service_account.sa-writer.id
  }

  object_storage {
    bucket_id = var.log_bucket_name
    prefix    = var.kyverno_prefix
    create    = true
    update    = false
    delete    = false
  }
}
