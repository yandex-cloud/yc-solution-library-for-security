
//----------------------Подготовка тестовой инфраструктуры-----------------------------------
//Генерация random-string для имени bucket---------------------------------------------------------
resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false 
}
//Создание сети
resource "yandex_vpc_network" "vpc-elk" {
  name = "vpc-elk"
}
//Создание подсетей
resource "yandex_vpc_subnet" "elk-subnet" {
  folder_id = var.folder_id

  count          = 3
  name           = "app-elk-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-elk.id
  v4_cidr_blocks = [element(var.app_cidrs, count.index)]
}
//Создание sa storage admin для создания Bucket for AuditTrail
resource "yandex_iam_service_account" "sa-bucket-creator" {
  name        = "sa-bucket-creator"
  folder_id = var.folder_id
}
//Создание стат ключа
resource "yandex_iam_service_account_static_access_key" "sa-bucket-creator-sk" {
  service_account_id = yandex_iam_service_account.sa-bucket-creator.id
}
//Назначение прав для создания бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id = var.folder_id

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-creator.id}",
  ]
}

//Создание S3 bucket для AuditTrails
resource "yandex_storage_bucket" "trail-bucket" {
  bucket = "trails-audit-log-bucket-${random_string.random.result}"

  access_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.secret_key
}

//Создание sa storage editor для работы от ELK с Bucket for AuditTrail
resource "yandex_iam_service_account" "sa-bucket-editor" {
  name        = "sa-bucket-editor"
  folder_id = var.folder_id
}

//Назначение прав для изменения бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_editor" {
  folder_id = var.folder_id

  role = "storage.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-editor.id}",
  ]
}

//Обязательно включить AuditTrail в UI на созданный bucket
//Обязательно включить Egress NAT для подсети COI в UI на созданный bucket



//----------------------Вызов модулей-----------------------------------


module "yc-splunk-trail" {
    source = "../modules/yc-splunk-trail/" #path to module yc-elastic-trail
    
    folder_id = var.folder_id
    splunk_token = var.splunk_token //выполнить команду: export TF_VAR_splunk_token=<SPLUNK TOKEB> (заменить SPLUNK TOKEN на ваше значение)
    splunk_server = "https://84.252.128.64:8088" //формат "https://<your hostname or address>:8088"
    bucket_name = yandex_storage_bucket.trail-bucket.bucket // //указать имя bucket с trails если вызов не из example
    bucket_folder = "folder" //указанный при создании Trails
    sa_id = yandex_iam_service_account.sa-bucket-editor.id //указать sa с правами  bucket_editor  если вызов не из example
    coi_subnet_id = yandex_vpc_subnet.elk-subnet[0].id //указать subnet_id если вызов не из example
}


