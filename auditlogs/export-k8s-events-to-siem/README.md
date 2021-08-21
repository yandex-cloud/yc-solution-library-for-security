## Анализ логов безопасности k8s в ELK: аудит-логи, policy engine, falco 

![Logo-scheme](https://user-images.githubusercontent.com/85429798/130331398-27cc1d8f-0b2c-4c1d-9be5-b1186116b618.png)

![Снимок экрана 2021-08-20 в 12 05 25](https://user-images.githubusercontent.com/85429798/130331405-26a909ae-0171-47b2-93a2-c656632d262c.png)

![Снимок экрана 2021-08-20 в 12 05 48](https://user-images.githubusercontent.com/85429798/130331411-cf016471-ad7b-49d6-870a-f13f07ba79b5.png)


#### Описание 
Решение устанавливает falco и импортирует аудит-логи k8s, алерты falco в Managed ELK SIEM. Также импортирует security content (dashboards, detection rules и др.) в ELK для анализа и реагирования на события ИБ. В том числе "из коробки" анализирует срабатывания Policy Engine (OPA Gatekeeper).

#### Общая схема 

Схема сбора


#### Описание импортируемых объектов ELK (security content)
Подробное описание объектов по ссылке [yc-solution-library-for-security/auditlogs/export-auditlogs-to-ELK(main)/papers/Описание объектов.pdf](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK(main)/papers)

#### Описание terraform 

Решение состоит из 2-х модулей Terraform:
1) security-events-to-storage-exporter (экспортирует логи в s3)
- Принимает на вход: 
    - folder_id (id каталога в котором лежит кластер)
	- cluster_name (имя кластера k8s)
	- log_bucket_service_account_id - id сервис аккаунта который может писать в бакет и имеет роль ymq.admin
	- log_bucket_name - имя бакета куда писать лог
	- function_service_account_id - ( опционально) id сервисного аккаунта который будет запускать фукнцию , если не указан то используется log_bucket_service_account_id

- Выполняет: 
	- создание статического ключа для сервисного аккаунта
	- создание функции и тригера для записи логов кластера в s3
	- установку falco и настроенного falcosidekick, который отправит логи в s3
	- скоро: установку Kyverno в режиме аудит и Policy Reporter (https://github.com/kyverno/policy-reporter)

2) security-events-to-siem-importer (импортирует логи в ELK)
- Принимает на вход: 
    - ряд параметров из модуля (security-events-to-storage-exporter)
    - "auditlog_enabled" true или false (отправлять ли аудит логи k8s в ELK)
    - "falco_enabled" true или false (отправлять ли алерты falco в ELK)
    - fqdn ELK server
    - id подсети, в которой создается ВМ с контейнером импортера
    - credentials ELK пользователя для импорта событий

- Выполняет: 
	- создание ymq очередей с именами файлов логов в s3
    - создание функций для push имен файлов из s3 в ymq
    - создание тригеров для взаимодействия очередей и функций
    - генерацию и запись в файл и на ВМ ssh ключей
    - создание ВМ на базе COI (container optimised image) с контейнерами workers. Они импортируют событий из s3 в ELK

#### Пререквизиты
- :white_check_mark: Cluster Managed k8s
- :white_check_mark: Managed ELK
- :white_check_mark: сервис аккаунт, который может писать в бакет и имеет роль ymq.admin
- :white_check_mark: Object Storage Bucket 
- :white_check_mark: subnet для развертывания ВМ с включенным NAT


#### Дополнительное действие: установка OPA Gatekeeper (helm)
Установите OPA Gatekeeper с помощью helm - https://open-policy-agent.github.io/gatekeeper/website/docs/install/#deploying-via-helm
Выбрать и установить необходимые contstraint temnplate и constraint из [gatekeeper-library](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy) 
[Пример установки](https://github.com/open-policy-agent/gatekeeper-library#usage)


#### Пример вызова модулей:
```Python

//Вызов модуля security-events-to-storage-exporter
module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # путь до модуля

    folder_id = "b1g30dckl1ctvpjqdudf" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "k8s-exporter1" //имя кластера

    log_bucket_service_account_id = "ajemr9kufi6si6p778n0" //id sa (должен обладать ролями: ymq.admin, write to bucket)
    
    log_bucket_name = "k8s-exporter1" //можно подставить из конфига развертывания
    #function_service_account_id = "чч" // опциоанальный id сервисного аккаунта который вызывает функции - если не выставлен то функция вызывается от имени log_bucket_service_account_id
}


//Вызов модуля security-events-to-siem-importer
module "security-events-to-siem-importer" {
    source = "../security-events-to-siem-importer/" # путь до модуля

    folder_id = module.security-events-to-storage-exporter.folder_id 
    
    service_account_id = module.security-events-to-storage-exporter.service_account_id
    
    auditlog_enabled = true //отправлять k8s auditlog в elk
    
    falco_enabled = true // отправлять алерты falco в elk 

    log_bucket_name = module.security-events-to-storage-exporter.log_bucket_name

    elastic_server = "https://c-c9q5s2n6ihabttfdt9r1.rw.mdb.yandexcloud.net" // url ELK "https://c-xxx.rw.mdb.yandexcloud.net" (можно подставить из модуля module.yc-managed-elk.elk_fqdn)

    coi_subnet_id = "e9bifj73ht64lu8g19su" // subnet id в которой будет развернута ВМ с контейнером (обязательно включить NAT)

    elastic_pw = "P@ssw0rd" // пароль учетной записи ELK (можно подставить из модуля module.yc-managed-elk.elk-pass)
    
    elastic_user = "admin" // имя учетной записи ELK
}
    
```
