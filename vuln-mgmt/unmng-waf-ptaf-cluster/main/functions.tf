//Создание sa для функции и тригера
resource "yandex_iam_service_account" "sa-ptaf" {
  name        = "sa-ptaf-${var.folder_id}"
  description = "service account for ptaf func"
  folder_id = var.folder_id
}


//Назначение прав 
resource "yandex_resourcemanager_folder_iam_binding" "func-admin" {
  folder_id = var.folder_id

  role = "serverless.functions.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ptaf.id}",
  ]
}

//Назначение прав 
resource "yandex_resourcemanager_folder_iam_binding" "func-admin2" {
  folder_id = var.folder_id

  role = "viewer"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ptaf.id}",
  ]
}

//Назначение прав 
resource "yandex_resourcemanager_folder_iam_binding" "func-admin3" {
  folder_id = var.folder_id

  role = "logging.writer"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ptaf.id}",
  ]
}

//Назначение прав 
resource "yandex_resourcemanager_folder_iam_binding" "func-admin4" {
  folder_id = var.folder_id

  role = "load-balancer.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ptaf.id}",
  ]
}

//Создание функции

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/sync.zip"
  depends_on = [
    yandex_lb_network_load_balancer.int-lb,
  ]
}


resource "yandex_function" "bypass" {
  folder_id = var.folder_id
  name               = "bypass-function"
  runtime            = "bash"
  entrypoint         = "handler.sh"
  memory             = "128"
  execution_timeout  = "200"
  service_account_id = yandex_iam_service_account.sa-ptaf.id

  environment = {
      test = var.folder_id
      folderid = var.folder_id
      tgwafid = yandex_lb_target_group.ptaf_group.id
      tgvmid = var.app_target_group_id
      elb = yandex_lb_network_load_balancer.ext-lb.name
      ilb = yandex_lb_network_load_balancer.int-lb.name 
  }

  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

//Сощздание триггера
resource "yandex_function_trigger" "bypass-trigger" {
  name        = "bypass-trigger"
  description = "any description"
  depends_on = [
    yandex_lb_network_load_balancer.int-lb,
  ]
  timer {
    cron_expression = "*/5 * * * ? *"
  }
  function {
    id = yandex_function.bypass.id
    service_account_id = yandex_iam_service_account.sa-ptaf.id
  }
}

