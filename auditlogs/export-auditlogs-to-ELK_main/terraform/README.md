## Развертывание с помощью Terraform

#### Описание 

Решение состоит из 2-х модулей Terraform [/terraform/modules/](ссылка) :
1) yc-managed-elk:
- создает cluster [Yandex Managed Service for Elasticsearch](https://cloud.yandex.ru/services/managed-elasticsearch) 
- с 3 нодами (1 на зону доступности) 
- с лицензией Gold
- характеристики: s2-medium (8vCPU, 32Gb Memory)
- HDD: 1TB
- назначает пароль на аккаунт admin в ELK

2) yc-elastic-trail:
- создает static keys для sa (для работы с объектами JSON в бакете и шифрования/расшифрования секретов)
- создает ВМ COI со спецификацией Docker Container со скриптом
- создает ssh пару ключей и сохраняет приватную часть на диск, публичную в ВМ
- создает KMS ключ
- назначает права kms.keys.encrypterDecrypter на ключ для sa для шифрование секретов
- шифрует секреты и передает их в Docker Container

#### Пререквизиты
- :white_check_mark: Object Storage Bucket для AuditTrails
- :white_check_mark: Включенный сервис AuditTrail в UI
- :white_check_mark: Сеть VPC
- :white_check_mark: Подсети в 3-х зонах доступности
- :white_check_mark: ServiceAccount с ролью storage.editor для действий в Object Storage

**См. Пример конфигурации пререквизитов в /example/main.tf**


#### Пример вызова модулей:
```Python
module "yc-managed-elk" {
    source     = "../modules/yc-managed-elk" # path to module yc-managed-elk    
    folder_id  = var.folder_id
    subnet_ids = yandex_vpc_subnet.elk-subnet[*].id  # subnets в 3-х зонах доступности для развертывания ELK
    network_id = yandex_vpc_network.vpc-elk.id # network id в которой будет развернут ELK
}

module "yc-elastic-trail" {
    source          = "../modules/yc-elastic-trail/" # path to module yc-elastic-trail
    folder_id       = var.folder_id
    elk_credentials = module.yc-managed-elk.elk-pass
    elk_address     = module.yc-managed-elk.elk_fqdn
    bucket_name     = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder   = "" # указать название префикса куда trails пишет логи в бакет, например "prefix-trails", если в корень то оставить по умолчанию пустым
    sa_id           = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id   = yandex_vpc_subnet.elk-subnet[0].id
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
    
```
