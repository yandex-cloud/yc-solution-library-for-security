//Генерация random-string для имени bucket---------------------------------------------------------
resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false 

}

//---------------------------------------------------------------------------------------------
//Создание sa storage admin для создания bucket 
resource "yandex_iam_service_account" "sa-creator" {
  name        = "sa-creator-${random_string.random.result}"
  description = "service account to create bucket for audit-logs"
  folder_id = var.folder_id
}

//Создание стат ключа
resource "yandex_iam_service_account_static_access_key" "tr-sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-creator.id
  description        = "static access key for object storage"
}

//Назначение прав 
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id = var.folder_id

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-creator.id}",
  ]
}

//Назначение прав на KMS ключи для работы с шифрованным бакетом для sa-creator
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-sa-creator" {
  folder_id = var.folder_id

  role = "kms.keys.encrypterDecrypter"

  members = ["serviceAccount:${yandex_iam_service_account.sa-creator.id}"] 
}

/*
//Назначение прав на KMS ключи для работы с шифрованным бакетом для группы all-access
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-all-access" {
  count = length(var.all-access-users)
  folder_id = var.folder_id

  role = "kms.keys.encrypterDecrypter"

  members = [element(var.all-access-users, count.index)]
}
*/

//Назначение прав на KMS ключи для работы с шифрованным бакетом для группы read-only-sa
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-read-only-sa" {
  count = length(var.read-only-sa)
  folder_id = var.folder_id

  role = "kms.keys.encrypterDecrypter"

  members = [element(var.read-only-sa, count.index)]
}

//Назначение прав на KMS ключи для работы с шифрованным бакетом для группы write-only-sa
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-write-only-sa" {
  count = length(var.write-only-sa)
  folder_id = var.folder_id

  role = "kms.keys.encrypterDecrypter"

  members = [element(var.write-only-sa, count.index)]
}

//-------------------------------------------------------------------------------------------------
//Назначение прав группам УЗ
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-all-access2" {
  count = length(var.all-access-users)
  folder_id = var.folder_id

  role = "storage.admin"

  members = [element(var.all-access-users, count.index)]
}

resource "yandex_resourcemanager_folder_iam_binding" "binding-for-read-only-sa2" {
  count = length(var.read-only-sa)
  folder_id = var.folder_id

  role = "storage.viewer"

  members = [element(var.read-only-sa, count.index)]
}

resource "yandex_resourcemanager_folder_iam_binding" "binding-for-write-only-sa2" {
  count = length(var.write-only-sa)
  folder_id = var.folder_id

  role = "storage.uploader"

  members = [element(var.write-only-sa, count.index)]
}



//-------------------------------------------------------------------------------------------------
//Операции с S3:

//Создание KMS ключа для server-side encryption
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "key-for-bucket-k8s-logs"
  description       = "description for key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}


//Cоздание отдельного S3 bucket для логирования действий 
resource "yandex_storage_bucket" "log_bucket" {
  bucket = "action-log-${random_string.random.result}"
  access_key = yandex_iam_service_account_static_access_key.tr-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tr-sa-static-key.secret_key
}

//-------------------------------------------------
//Создание основного S3 bucket 
resource "yandex_storage_bucket" "bucket-main" {
  bucket = "bucket-main-${random_string.random.result}"

  access_key = yandex_iam_service_account_static_access_key.tr-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tr-sa-static-key.secret_key


//Создание BucketPolicy:
  policy = <<POLICY
{"Version":"2012-10-17","Id":"myid","Statement":[{"Sid":"rule-admin-for-terr-admin","Effect":"Allow","Principal":{"CanonicalUser":["${yandex_iam_service_account.sa-creator.id}"]},"Action":"*","Resource":["arn:aws:s3:::bucket-main-${random_string.random.result}/*","arn:aws:s3:::bucket-main-${random_string.random.result}"]}, {"Sid":"rule-all-access-users","Effect":"Allow","Principal":{"CanonicalUser":[${replace("${join(", ", [for s in var.all-access-users : format("%q", s)])}", "federatedUser:", "")}]},"Action":"*","Resource":["arn:aws:s3:::bucket-main-${random_string.random.result}/*","arn:aws:s3:::bucket-main-${random_string.random.result}"]}, {"Sid":"rule-admin-web","Effect":"Allow","Principal":{"CanonicalUser":[${replace("${join(", ", [for s in var.all-access-users : format("%q", s)])}", "federatedUser:", "")}]},"Action":"*","Resource":["arn:aws:s3:::bucket-main-${random_string.random.result}/*","arn:aws:s3:::bucket-main-${random_string.random.result}"], "Condition": {"StringLike": {"aws:referer": "https://console.cloud.yandex.*/folders/*/storage/bucket/bucket-main-${random_string.random.result}*"}}}, {"Sid":"rule-write-only-sa","Effect":"Allow","Principal":{"CanonicalUser":[${replace("${join(", ", [for s in var.write-only-sa : format("%q", s)])}", "serviceAccount:", "")}]},"Action":"s3:PutObject" ,"Resource":["arn:aws:s3:::bucket-main-${random_string.random.result}/*","arn:aws:s3:::bucket-main-${random_string.random.result}"]}, {"Sid":"rule-read-only-sa","Effect":"Allow","Principal":{"CanonicalUser":[${replace("${join(", ", [for s in var.read-only-sa : format("%q", s)])}", "serviceAccount:", "")}]},"Action":["s3:ListBucket", "s3:GetObject"],"Resource":["arn:aws:s3:::bucket-main-${random_string.random.result}/*","arn:aws:s3:::bucket-main-${random_string.random.result}"]}]}
POLICY

 //Включение версионирования
  versioning {
    enabled = true
  }
//Настройка жизненного цикла: удаление НЕтекущих версий и текущих версий 
  lifecycle_rule {
    id      = "cleanupoldlogs"
    enabled = true
    expiration {
      days = 365
    }
  }
  lifecycle_rule {
    id      = "cleanupoldversions"
    enabled = true
    noncurrent_version_transition {
      days          = 60
      storage_class = "COLD"
    }
    noncurrent_version_expiration {
      days = 150
    }
  }

//Включение логирования действий над бакетом
  logging {
    target_bucket = yandex_storage_bucket.log_bucket.id
    target_prefix = "logs/"
  }


//Включение шифрования

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  }

//-----------------------------------------------------------------------------------------------------



