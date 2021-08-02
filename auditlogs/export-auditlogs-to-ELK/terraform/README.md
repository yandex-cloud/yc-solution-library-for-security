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

См. Пример конфигурации пререквизитов в /example/main.tf 


#### Пример вызова модулей:
```Python
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

output "elk-user" {
      value = "admin"
    }
    
```
