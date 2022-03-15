# Сбор, мониторинг и анализ аудит логов во внешний SIEM Splunk

![Дашборд](https://user-images.githubusercontent.com/85429798/130447006-c5a604b3-d1ed-4f47-b132-5e83f02494c8.png)

![Дашборд](https://user-images.githubusercontent.com/85429798/130446967-926e892c-0dcb-4a97-93bc-92fe67b078dd.png)


## Описание решения
Решение позволяет собирать, мониторить и анализировать аудит логи в Yandex.Cloud со следующих источников:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)
- [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/) **(скоро)** 

## Use cases and searches
Команда безопасности Yandex.Cloud собрала наиболее интересные сценарии use cases в [папке](../_use_cases_and_searches) репозитория auditlogs.
Вы можете описанные сценарии для реагирования на события в части информационной безопасности.

## Что делает решение (через Terraform)
- [x] Разворачивает COI Instance с контейнером на базе образа s3-splunk-importer (`cr.yandex/sol/s3-splunk-importer:1.0`)
- [x] Обеспечивает непрерывную доставку json файлов с аудит логами из Yandex Object Storage в Splunk

## Схема решения
![Схема](https://user-images.githubusercontent.com/85429798/130447027-efdd1ee7-0c1b-46fb-b0f2-36577bb5e6a4.png)


## Развертывание с помощью Terraform

## Описание 

#### Пререквизиты Yandex Cloud
- :white_check_mark: Object Storage Bucket для Audit Trails
- :white_check_mark: Включенный сервис Audit Trails в UI
- :white_check_mark: Сеть VPC
- :white_check_mark: Наличие доступа в интернет с COI Instance для скачивания образа контейнера (например source NAT на подсеть)
- :white_check_mark: ServiceAccount с ролью *storage.editor* для действий в Object Storage

##### См. Пример конфигурации пререквизитов в /example/main.tf

#### Пререквизиты Splunk
- :white_check_mark: Настроенный [HTTP Event Collector](https://docs.splunk.com/Documentation/SplunkCloud/8.2.2105/Data/UsetheHTTPEventCollector#Configure_HTTP_Event_Collector_on_Splunk_Enterprise)
- :white_check_mark: Токен для отправки событий в HEC

Модуль Terraform /modules/yc-splunk-trail:

- создает static keys для sa (для работы с объектами JSON в бакете и шифрования/расшифрования секретов)
- создает ВМ COI со спецификацией Docker Container со скриптом
- создает ssh пару ключей и сохраняет приватную часть на диск, публичную в ВМ
- создает KMS ключ
- назначает права *kms.keys.encrypterDecrypter* на ключ для sa для шифрование секретов
- шифрует секреты и передает их в Docker Container


#### Пример вызова модуля:
```Python
module "yc-splunk-trail" {
    source = "../modules/yc-splunk-trail/" #path to module yc-elastic-trail
    
    folder_id = var.folder_id
    splunk_token = var.splunk_token // выполнить команду: export TF_VAR_splunk_token=<SPLUNK TOKEB> (заменить SPLUNK TOKEN на ваше значение)
    splunk_server = "https://1.2.3.4" // формат "https://<your hostname or address>"
    bucket_name = yandex_storage_bucket.trail-bucket.bucket // указать имя bucket с audit trails, если вызов не из example
    bucket_folder = "folder" // указанный при создании Trails
    sa_id = yandex_iam_service_account.sa-bucket-editor.id // указать sa с правами bucket_editor, если вызов не из example
    coi_subnet_id = yandex_vpc_subnet.splunk-subnet[0].id // указать subnet_id, если вызов не из example
}

```