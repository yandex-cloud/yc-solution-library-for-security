
## Описание


## Пререквизиты
:white_check_mark: Object Storage Bucket для AuditTrails
:white_check_mark: Включенный сервис AuditTrail в UI
:white_check_mark: Сеть VPC
:white_check_mark: Подсети в 3-х зонах доступности
:white_check_mark: ServiceAccount с ролью storage.editor для действий в Object Storage

См. Пример конфигурации пререквизитов в /example/main.tf 


## Пример вызова модулей:
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
    elk_credentials = module.First-module.elk-pass
    elk_address = module.First-module.elk_fqdn
    bucket_name = "bucket-mirtov8"
    bucket_folder = "folder"
    sa_id = "aje5h5587p1bffca503j"
    coi_subnet_id = "e9boih92qspkol5morvl"
}

output "elk-pass" {
      value = module.First-module.elk-pass
      sensitive = true
    }
//Чтобы посмотреть пароль ELK выполните команду: terraform output elk-pass

output "elk_fqdn" {
      value = module.First-module.elk_fqdn
    }

//Выводит адрес ELK на который можно обращаться, например через браузер 
```
