//выдача прав на создание функции
resource "yandex_resourcemanager_folder_iam_binding" "create_funct" {
  count = var.function_service_account_id != "" ? 0 : 1
  folder_id = var.folder_id

  role = "serverless.functions.admin"

  members = [
    "serviceAccount:${data.yandex_iam_service_account.bucket_sa.id}",
  ]
}


//--------
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/sync.zip"
}


resource "yandex_function" "k8s_log_exporter" {
  folder_id = var.folder_id
  name               = "k8s-log-exporter-for-cluster-${data.yandex_kubernetes_cluster.my_cluster.id}"
  runtime            = "python38"
  entrypoint         = "main.handler"
  memory             = "128"
  execution_timeout  = "30"
  service_account_id = var.function_service_account_id != "" ? var.function_service_account_id : data.yandex_iam_service_account.bucket_sa.id

  environment = {
      AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.sa_static_key.access_key
      AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
      BUCKET_NAME = var.log_bucket_name
      CLOUD_ID = data.yandex_resourcemanager_folder.my_folder.cloud_id
      CLUSTER_ID = data.yandex_kubernetes_cluster.my_cluster.id
      FOLDER_ID = var.folder_id
      
  }

  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

resource "yandex_function_trigger" "logs-trigger" {
  name = "k8s-log-trigger-${data.yandex_kubernetes_cluster.my_cluster.id}"
  folder_id = var.folder_id
  function {
    id = yandex_function.k8s_log_exporter.id
    service_account_id = var.function_service_account_id != "" ? var.function_service_account_id : data.yandex_iam_service_account.bucket_sa.id
  }
  log_group {
    log_group_ids = [
      data.yandex_kubernetes_cluster.my_cluster.log_group_id,
    ]
    batch_cutoff = 10
    batch_size   = 100
  }
}

