//----------------------Подготовка тестовой инфраструктуры-----------------------------------
// Генерация random-string для имени bucket---------------------------------------------------------
resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false 
}

// Создание сети
resource "yandex_vpc_network" "vpc-elk" {
  name = "vpc-elk"
}

// Создание подсетей
resource "yandex_vpc_subnet" "elk-subnet" {
  folder_id      = var.folder_id
  count          = 3
  name           = "app-elk-${element(var.network_names, count.index)}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.vpc-elk.id
  v4_cidr_blocks = [element(var.app_cidrs, count.index)]
}

// Создание sa storage admin для создания Bucket for AuditTrail
resource "yandex_iam_service_account" "sa-bucket-creator" {
  name        = "sa-bucket-creator-${random_string.random.result}"
  folder_id = var.folder_id
}

// Создание статического ключа
resource "yandex_iam_service_account_static_access_key" "sa-bucket-creator-sk" {
  service_account_id = yandex_iam_service_account.sa-bucket-creator.id
}

// Назначение прав для создания бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-creator.id}",
  ]
}

// Создание S3 bucket для AuditTrails
resource "yandex_storage_bucket" "trail-bucket" {
  bucket = "trails-audit-log-bucket-${random_string.random.result}"

  access_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.secret_key
}

// Создание sa storage editor для работы от ELK с Bucket for AuditTrail
resource "yandex_iam_service_account" "sa-bucket-editor" {
  name        = "sa-bucket-editor-${random_string.random.result}"
  folder_id = var.folder_id
}

// Назначение прав для изменения бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-editor.id}",
  ]
}

// Обязательно включить AuditTrail в UI на созданный bucket
// Обязательно включить Egress NAT для подсети COI в UI на созданный bucket

//----------------------Вызов модулей-----------------------------------

module "yc-managed-elk" {
    source                  = "../modules/yc-managed-elk" # path to module yc-managed-elk    
    folder_id               = var.folder_id
    subnet_ids              = yandex_vpc_subnet.elk-subnet[*].id  # subnets в 3-х зонах доступности для развертывания ELK
    network_id              = yandex_vpc_network.vpc-elk.id # network id в которой будет развернут ELK
    elk_edition             = "gold"
    elk_datanode_preset     = "s2.medium"
    elk_datanode_disk_size  = 1000
    elk_public_ip           = true
}

module "yc-elastic-trail" {
    source                  = "../modules/yc-elastic-trail/" # path to module yc-elastic-trail
    folder_id               = var.folder_id
    elk_credentials         = module.yc-managed-elk.elk-pass
    elk_address             = module.yc-managed-elk.elk_fqdn
    bucket_name             = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder           = "" # указать название префикса куда trails пишет логи в бакет, например "prefix-trails", если в корень то оставить по умолчанию пустым
    sa_id                   = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id           = yandex_vpc_subnet.elk-subnet[0].id
}

output "elk-pass" {
  value     = module.yc-managed-elk.elk-pass
  sensitive = true
} // Чтобы посмотреть пароль ELK: terraform output elk-pass
output "elk_fqdn" {
  value = module.yc-managed-elk.elk_fqdn
} // Выводит адрес ELK на который можно обращаться, например через браузер 

output "elk-user" {
  value = "admin"
}