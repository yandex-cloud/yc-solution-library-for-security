

data "archive_file" "checker_function" {
  type        = "zip"
  source_dir  = "${path.module}/functions/checker_function/"
  output_path = "${path.module}/checker_function.zip"
}

resource "yandex_function" "checker_function" {
  folder_id          = var.folder_id
  name               = "route-checker-for-${var.vpc_id}"
  runtime            = "python38"
  entrypoint         = "main.handler"
  memory             = "128"
  execution_timeout  = "600"
  service_account_id = var.sa_id
  environment = {
    AWS_ACCESS_KEY_ID     = var.access_key
    AWS_SECRET_ACCESS_KEY = var.secret_key
    BUCKET_NAME           = var.bucket_id
    CONFIG_PATH           = "config-${var.vpc_id}.yaml"
    YMQ_URL = yandex_message_queue.route_switcher_queue.id

  }
  user_hash = data.archive_file.checker_function.output_base64sha256
  content {
    zip_filename = data.archive_file.checker_function.output_path
  }
}

resource "yandex_function_trigger" "checker_function_trigger" {
  folder_id = var.folder_id

  name = "route-swicher-checker-function-${var.vpc_id}"

  function {
    id                 = yandex_function.checker_function.id
    service_account_id = var.sa_id
  }

  timer {
    cron_expression = "* * * * ? *"
  }
}
