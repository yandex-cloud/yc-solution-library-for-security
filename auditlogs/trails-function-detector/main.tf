data "yandex_iam_service_account" "sa" {
  service_account_id = var.service_account_id
}

//выдача прав на вызов функции
resource "yandex_resourcemanager_folder_iam_binding" "invoker_bind" {
  folder_id = var.folder_id

  #role = "serverless.functions.admin"
  role = "serverless.functions.invoker" 

  members = [
    "serviceAccount:${data.yandex_iam_service_account.sa.id}",
  ]
}

//выдача прав editor, если var.del_rule_on=True
resource "yandex_resourcemanager_folder_iam_binding" "remediation_bind_1" {
  count = var.del_rule_on != "True" ? 0 : 1
  folder_id = var.folder_id

  #role = "serverless.functions.admin"
  role = "editor" 

  members = [
    "serviceAccount:${data.yandex_iam_service_account.sa.id}",
  ]
}

//выдача прав editor, если var.del_perm_secret_on=True
resource "yandex_resourcemanager_folder_iam_binding" "remediation_bind_2" {
  count = var.del_perm_secret_on != "True" ? 0 : 1
  folder_id = var.folder_id

  #role = "serverless.functions.admin"
  role = "editor" 

  members = [
    "serviceAccount:${data.yandex_iam_service_account.sa.id}",
  ]
}

//--------
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/sync.zip"
}


resource "yandex_function" "function-for-trails" {
  folder_id = var.folder_id
  name               = "function-for-trails"
  runtime            = "python38"
  entrypoint         = "main.handler"
  memory             = "128"
  execution_timeout  = "30"
  service_account_id = data.yandex_iam_service_account.sa.id

  environment = {
      BOT_TOKEN = var.bot_token
      CHAT_ID = var.chat_id_var
      EVENT_DICT = var.any_event_dict
      RULE_SG_ON = var.rule_sg_on
      RULE_BUCKET_ON = var.rule_bucket_on
      RULE_SECRET_ON = var.rule_secret_on
      DEL_RUL_ON = var.del_rule_on
      DEL_PERM_SECRET_ON = var.del_perm_secret_on      
  }

  user_hash = data.archive_file.function.output_base64sha256
  content {
    zip_filename = data.archive_file.function.output_path
  }
}

/*Доделать когда появится триггер для cloudlogging в terraform
resource "yandex_function_trigger" "logs-trigger" {
  name = "trails-log-trigger"
  folder_id = var.folder_id
  function {
    id = yandex_function.function-for-trails.id
    service_account_id = data.yandex_iam_service_account.sa.id
  }
  log_group {
    log_group_ids = [
      var.loggroup_id,
    ]
    batch_cutoff = 10
    batch_size   = 5
  }
}
*/