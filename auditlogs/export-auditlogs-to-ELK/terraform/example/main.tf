//создать prepare тераформ скрипт
//readme (если хотите обновить индексы)
//переименовать модули: yc-managed-elk, yc-elastic-trail

//Пререквизиты: 
//-наличие сети
//-наличие подсетей в 3-х зонах
//-наличие SA
//-наличие бакета с trail json

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
  folder_id = var.log_bucket_folder_id

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-creator.id}",
  ]
}

//Создание S3 bucket для AuditTrails
resource "yandex_storage_bucket" "k8s-audit-logs" {
  bucket = "k8s-audit-log-bucket-${random_string.random.result}"

  access_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.secret_key
}

//Обязательно включить AuditTrail в UI на созданный bucket




//----------------------Вызов модулей-----------------------------------


module "yc-managed-elk" {
    source = "../modules/yc-managed-elk" #path to module yc-managed-elk
    
    folder_id = var.folder_id
    subnet_ids = ["e9boih92qspkol5morvl", "e2lbe671uvs0i8u3cr3s", "b0c0ddsip8vkulcqh7k4"]  #subnets в 3-х зонах доступности для развертывания ELK
    network_id = "enp5t00135hd1mut1to9" # network id в которой будет развернут ELK
}



module "yc-elastic-trail" {
    source = "../modules/yc-elastic-trail/" #path to module yc-elastic-trail
    
    folder_id = var.folder_id
    cloud_id = var.cloud_id
    elk_credentials = module.yc-managed-elk.elk-pass
    elk_address = module.yc-managed-elk.elk_fqdn
    bucket_name = "bucket-mirtov8"
    bucket_folder = "folder"
    sa_id = "aje5h5587p1bffca503j"
    coi_subnet_id = "e9boih92qspkol5morvl"
}

output "elk-pass" {
      value = module.yc-managed-elk.elk-pass
      sensitive = true
    }
//Чтобы посмотреть пароль ELK: terraform output elk-pass

output "elk_fqdn" {
      value = module.yc-managed-elk.elk_fqdn
    }
//Выводит адрес ELK на который можно обращаться, например через браузер 