# Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)

![dashboard](https://user-images.githubusercontent.com/85429798/127686785-27658104-6258-4de8-929f-9cf87624fa27.png)

## Оглавление
- [Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)](#----------------------------------------yandex-managed-service-for-elasticsearch--elk-)
  * [Описание решения:](#-----------------)
  * [Что делает решение:](#-------------------)
  * [Схема решения](#-------------)
  * [Security Content](#security-content)
  * [Лицензионные ограничения](#------------------------)
  * [Процесс обновления контента](#---------------------------)
  * [Развертывание с помощью Terraform](#------------------------terraform)
      - [Описание](#--------)
      - [Пререквизиты](#------------)
      - [Пример вызова модулей:](#----------------------)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


## Описание решения:
Решение позволяет собирать, мониторить и анализировать аудит логи в Yandex.Cloud со следующих источников:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)
- Скоро: [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)

Решение является постоянно обновляемым и поддерживаемым Security командой Yandex.Cloud

## Что делает решение:
- [x] Разворачивает в инфраструктуре Yandex.Cloud cluster Managed ELK (возможно через Terraform)
- [x] Разворачивает COI Instance с контейнером на базе образа s3-elk-importer (cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest)
- [x] Загружает Security Content в ELK (Dashboards, Detection Rules (с alerts), etc.)
- [x] Обеспечивает непрерывную доставку json файлов с аудит логами из Yandex Object Storage в ELK

## Схема решения
![Схема_решения](https://user-images.githubusercontent.com/85429798/127733565-d455b897-d1ca-4d43-8ee9-195bb7a7d5ab.png)


## Security Content
Security Content - объекты ELK, которые автоматически загружаются решением. Весь контент разработан с учетом многолетнего опыта Security команды Yandex.Cloud и на основе опыта Клиентов облака.

Содержит следующий Security Content:
- Dashboard, на котором отражены все use cases и полезная статистика
- Набор Saved query для удобного поиска Security событий
- Набор Detection rules (правила корреляции) на которые настроены оповещения (Клиенту самостоятельно необходимо указать назначение уведомлений)
- Все интересные поля событий преобразованы в формат [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/index.html), полная табличка маппинга в файле [/papers/Описание объектов.pdf](ссылка)

подробное описание в файле [/papers/ECS-mapping.docx](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK/papers/ECS-mapping_new.pdf)


## Лицензионные ограничения

![image](https://user-images.githubusercontent.com/85429798/127733756-1a751356-a0f3-492e-9a85-56d3a73e298f.png)
![image](https://user-images.githubusercontent.com/85429798/127733769-5ee2f70a-2162-487f-b236-9076c6d9c681.png)
[Описание различий с сайта ELK](https://www.elastic.co/subscriptions)

## Процесс обновления контента
Рекомендуется подписаться на обновления в данном репозитории для оповещений о наличии нового обновления.
Технически обновление контента выполняется за счет обновления версии контейнера cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest
Для обновления необходимо обеспечить удаления текущией версии image, скачивание новой версии, пересоздание контейнера:
-либо пересоздать COI Instance
-либо выполнить вышеуказанные действия вручную 


## Развертывание с помощью Terraform

#### Описание 

#### Пререквизиты
- :white_check_mark: Object Storage Bucket для AuditTrails
- :white_check_mark: Включенный сервис AuditTrail в UI
- :white_check_mark: Сеть VPC
- :white_check_mark: Подсети в 3-х зонах доступности
- :white_check_mark: Наличие доступа в интернет с COI Instance для скачивания образа контейнера
- :white_check_mark: ServiceAccount с ролью storage.editor для действий в Object Storage

См. Пример конфигурации пререквизитов в [/example/main.tf](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK/terraform/example) 
Решение состоит из 2-х модулей Terraform [/terraform/modules/](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK/terraform/modules) :
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
```
