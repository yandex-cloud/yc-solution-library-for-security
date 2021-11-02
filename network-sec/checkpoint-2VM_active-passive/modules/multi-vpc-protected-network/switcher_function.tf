

data "archive_file" "switcher_function" {
  type        = "zip"
  source_dir  = "${path.module}/functions/switcher_function/"
  output_path = "${path.module}/switcher_function.zip"
}

resource "yandex_function" "switcher_function" {
  folder_id          = var.folder_id
  name               = "route-switcher-for-${var.vpc_id}"
  runtime            = "python38"
  entrypoint         = "main.handler"
  memory             = "128"
  execution_timeout  = "600"
  service_account_id = var.sa_id
  environment = {
     
      BUCKET_NAME           = var.bucket_id
      CONFIG_PATH           = "config-${var.vpc_id}.yaml"
      YMQ_URL = yandex_message_queue.route_switcher_queue.id

    }
  user_hash = data.archive_file.switcher_function.output_base64sha256
  content {
    zip_filename = data.archive_file.switcher_function.output_path
  }
}

resource "yandex_function_trigger" "switcher_function_trigger" {
  folder_id = var.folder_id

  name        = "switcher-function-${var.vpc_id}"
  
  function {
    id = yandex_function.switcher_function.id 
    service_account_id = var.sa_id
  }

  message_queue {
      queue_id = yandex_message_queue.route_switcher_queue.arn
      service_account_id = var.sa_id
      batch_cutoff = 1
      batch_size = 1
  }
}