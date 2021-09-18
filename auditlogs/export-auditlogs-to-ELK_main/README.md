# Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)

![Дашборд](https://user-images.githubusercontent.com/85429798/127686785-27658104-6258-4de8-929f-9cf87624fa27.png)

# Оглавление

- [Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)](#-------yandex-managed-service-for-elasticsearch-elk)
  - [Описание решения](#-)
  - [Что делает решение](#--)
  - [Схема решения](#-)
  - [Security Content](#security-content)
  - [Лицензионные ограничения](#-)
  - [Процесс обновления контента](#--)
  - [Развертывание с помощью Terraform](#---terraform)
  - [Развертывание решения для поставки логов k8s:](#-----k8s)
  - [Рекомендации по настройке retention, rollover и snapshots:](#---retention-rollover--snapshots)

## Описание решения
Решение позволяет собирать, мониторить и анализировать аудит логи в Yandex.Cloud Managed Service for Elasticsearch (ELK) из следующих источников:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)
- [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/): аудит логи, алерты falco и Policy Engine (OPA Gatekeeper) ([описание настройки](../export-auditlogs-to-ELK_k8s))

> Решение является постоянно обновляемым и поддерживаемым Security-командой Yandex.Cloud.


## Что делает решение
- [x] Разворачивает в инфраструктуре Yandex.Cloud кластер Managed ELK (через Terraform) (в default конфигурации см. п. Terraform)(рассчитать необходимую конфигурацию для вашей инфраструктуры необходимо совместно с Cloud Архитектором)
- [x] Разворачивает COI Instance с контейнером на базе образа s3-elk-importer (`cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest`)
- [x] Загружает Security Content в ELK (Dashboards, Detection Rules (с alerts), etc.)
- [x] Обеспечивает непрерывную доставку json файлов с аудит логами из Yandex Object Storage в ELK

## Схема решения
![Схема решения](https://user-images.githubusercontent.com/85429798/129480037-cef97473-bba2-4589-b291-0578163d09fd.png)

[Схема решения для поставки логов k8s](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_k8s)


## Security Content
**Security Content** - объекты ELK, которые автоматически загружаются решением. Весь контент разработан с учетом многолетнего опыта Security команды Yandex.Cloud и на основе опыта Клиентов облака.

Содержит следующий Security Content:
- Dashboard, на котором отражены все use cases и полезная статистика
- Набор Saved Queries для удобного поиска Security событий
- Набор Detection Rules (правила корреляции) на которые настроены оповещения (Клиенту самостоятельно необходимо указать назначение уведомлений)
- Все интересные поля событий преобразованы в формат [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/index.html), полная табличка маппинга в файле [Описание объектов](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf)

Подробное описание в файле [ECS-mapping.docx](./papers/ECS-mapping_new.pdf)


## Лицензионные ограничения

![image](https://user-images.githubusercontent.com/85429798/127733756-1a751356-a0f3-492e-9a85-56d3a73e298f.png)
![image](https://user-images.githubusercontent.com/85429798/127733769-5ee2f70a-2162-487f-b236-9076c6d9c681.png)
[Описание различий с сайта ELK](https://www.elastic.co/subscriptions)

## Процесс обновления контента
Рекомендуется подписаться на обновления в данном репозитории для оповещений о наличии нового обновления.
Технически, обновление контента выполняется за счет обновления версии контейнера на новую версию `cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest`

Для обновления необходимо обеспечить удаления текущией версии образа, загрузку новой версии, пересоздание контейнера на основе нового образа:
- либо пересоздать COI Instance через terraform (который был использован для его деплоя)
- либо выполнить вышеуказанные действия вручную (удалить образ, удалить контейнер, перезагрузить ВМ)

Также, рекомендуется обновить контент Kibana (dashboards, detection rules, searches) - обновление производится при помощи единоразового запуска контейнера Updater.

```
docker run -it --rm -e ELASTIC_AUTH_USER='admin' -e ELASTIC_AUTH_PW='password' -e KIBANA_SERVER='https://xxx.rw.mdb.yandexcloud.net' --name elk-updater cr.yandex/crpjfmfou6gflobbfvfv/elk-updater:latest
```

## Развертывание с помощью Terraform

#### Описание 

#### Пререквизиты
- :white_check_mark: Object Storage Bucket для Audit Trails
- :white_check_mark: Включенный сервис Audit Trails в UI
- :white_check_mark: Сеть VPC
- :white_check_mark: Подсети в 3-х зонах доступности
- :white_check_mark: Наличие доступа в интернет с COI Instance для скачивания образа контейнера
- :white_check_mark: ServiceAccount с ролью *storage.editor* для действий в Object Storage

См. Пример конфигурации пререквизитов и вызова модулей в [/example/main.tf](./terraform/example) 
## 
Решение состоит из 2-х модулей Terraform [/terraform/modules/](./terraform/modules) :
1) yc-managed-elk:
- создает cluster [Yandex Managed Service for Elasticsearch](https://cloud.yandex.ru/services/managed-elasticsearch) 
- с тремя нодами (по одной на каждую зону доступности) 
- с лицензией Gold
- характеристики: s2-medium (8 vCPU, 32Gb Memory)
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

## Развертывание решения для поставки логов k8s:
[Развертывание решения для поставки логов k8s](../export-auditlogs-to-ELK_k8s)

## Рекомендации по настройке retention, rollover и snapshots:

[Рекомендации по настройке retention, rollover и snapshots](./CONFIGURE-HA.md)
