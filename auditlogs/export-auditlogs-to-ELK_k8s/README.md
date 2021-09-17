## Yandex Cloud: Анализ логов безопасности k8s в ELK: аудит-логи, policy engine, falco 

![Logo-scheme](https://user-images.githubusercontent.com/85429798/133788649-452b4d2f-7cfc-4fcc-9b6b-339ba8facb18.png)

![Дашборд](https://user-images.githubusercontent.com/85429798/130331405-26a909ae-0171-47b2-93a2-c656632d262c.png)

<img width="1403" alt="1" src="https://user-images.githubusercontent.com/85429798/133788731-3c410508-3539-4ba0-b873-85ae55d58b87.png">

![2](https://user-images.githubusercontent.com/85429798/133788762-75152c1a-ad93-4291-999d-7fc0739d2438.png)


#### Описание 
Решение из "коробки" выполняет следующее:
- ☑️ собирает [k8s AUDIT-LOGS](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/) в [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/)
- ☑️ устанавливает [FALCO](https://falco.org/) и собирает его [ALERTS](https://falco.org/docs/alerts/) в [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/)
- ☑️ устанавливает [Kyverno](https://kyverno.io/) c политиками категории [Pod Security Policy(Restricted)](https://kyverno.io/policies/?policytypes=Pod%2520Security%2520Standards%2520%28Restricted%29) в режиме audit и собирает его [ALERTS (PolicyReports)](https://kyverno.io/docs/policy-reports/) (при помощи [Policy Reporter](https://github.com/kyverno/policy-reporter))
- ☑️ импортирует Security Content (dashboards, detection rules и др.)(см. в секции Security Content) в [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/) для анализа и реагирования на события ИБ. 
- ✔️ *В том числе импортирует Security Content для [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/) (в режиме enforce). (сам OPA Gatekeeper может быть установлен вручную дополнительно)

#### Связь с решением "Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)"
Решение ["Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)"](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main) содержит информацию о том, как установить Yandex Managed Service for Elasticsearch (ELK) и собирать в него логи Audit Trails


#### Общая схема 

![Tech_scheme](https://user-images.githubusercontent.com/85429798/133788824-a1e2ae2d-c8e0-4a11-9ca9-f1a67607fc80.png)

#### Описание импортируемых объектов ELK (Security Content)
Подробное описание объектов по [ссылке](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf)

#### Описание terraform 

Решение состоит из 2-х модулей Terraform:
1) [security-events-to-storage-exporter](./security-events-to-storage-exporter) (экспортирует логи в s3)
- Принимает на вход: 
    - `folder_id` - id каталога, в котором расположен кластер
	- `cluster_name` - имя кластера Kubernetes
	- `log_bucket_service_account_id` - id сервисного аккаунта, который может писать в бакет и имеет роль *ymq.admin*
	- `log_bucket_name` - имя бакета, куда нужно сохранять логи
	- `function_service_account_id` - (опционально) id сервисного аккаунта, который будет запускать фукнцию, если не указан, то используется `log_bucket_service_account_id`

- Выполняет: 
	- создание статического ключа для сервисного аккаунта
	- создание функции и тригера для записи логов кластера в s3
	- установку falco и настроенного falcosidekick, который отправит логи в s3
    - установку Kyverno и настроенного [Policy Reporter](https://github.com/kyverno/policy-reporter), который отправит логи в s3

2) [security-events-to-siem-importer](./security-events-to-siem-importer) (импортирует логи в ELK)
- Принимает на вход: 
    - ряд параметров из модуля (`security-events-to-storage-exporter`)
    - `auditlog_enabled` - *true* или *false* (отправлять ли аудит логи k8s в ELK)
    - `falco_enabled` - *true* или *false* (отправлять ли алерты falco в ELK)
    - `kyverno_enabled` - *true* или *false* (отправлять ли алерты kyverno в ELK)
    - адрес FQDN инсталляции ELK 
    - id подсети, в которой создается ВМ с контейнером импортера
    - credentials ELK пользователя для импорта событий

- Выполняет: 
	- создание YMQ очередей с именами файлов логов в S3
    - создание функций для push имен файлов из S3 в YMQ
    - создание тригеров для взаимодействия очередей и функций
    - генерацию и запись в файл и на ВМ ключей SSH
    - создание ВМ на базе COI ([container optimised image](https://cloud.yandex.ru/docs/cos/concepts/)) с контейнерами workers, которые импортируют событий из s3 в ELK

#### Пререквизиты
- :white_check_mark: Cluster Managed k8s
- :white_check_mark: Managed ELK
- :white_check_mark: Сервисный аккаунт, который может писать в бакет и имеет роль *ymq.admin*
- :white_check_mark: Object Storage Bucket 
- :white_check_mark: Subnet для развертывания ВМ с включенным NAT


#### Пример вызова модулей:
См. Пример вызова модулей в /example/main.tf 

```Python

//Вызов модуля security-events-to-storage-exporter
module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # путь до модуля

    folder_id = "xxxxxx" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "k8s-cluster" // имя кластера

    log_bucket_service_account_id = "xxxxxx" // id sa (должен обладать ролями: ymq.admin, write to bucket)
    
    log_bucket_name = "k8s-bucket" // можно подставить из конфига развертывания
    # function_service_account_id = "чч" // опциоанальный id сервисного аккаунта который вызывает функции - если не выставлен то функция вызывается от имени log_bucket_service_account_id
}


//Вызов модуля security-events-to-siem-importer
module "security-events-to-siem-importer" {
    source = "../security-events-to-siem-importer/" # путь до модуля

    folder_id = module.security-events-to-storage-exporter.folder_id 
    
    service_account_id = module.security-events-to-storage-exporter.service_account_id
    
    auditlog_enabled = true //отправлять k8s auditlog в elk
    
    falco_enabled = true //  установить falco и отправлять его алерты в elk

    kyverno_enabled = true // установить kyverno и отправлять его алерты в elk

    log_bucket_name = module.security-events-to-storage-exporter.log_bucket_name

    elastic_server = "https://c-xxx.rw.mdb.yandexcloud.net" // url ELK "https://c-xxx.rw.mdb.yandexcloud.net" (можно подставить из модуля module.yc-managed-elk.elk_fqdn)

    coi_subnet_id = "xxxxxx" // subnet id в которой будет развернута ВМ с контейнером (обязательно включить NAT)

    elastic_pw = "P@ssw0rd!" // пароль учетной записи ELK (можно подставить из модуля module.yc-managed-elk.elk-pass)
    
    elastic_user = "admin" // имя учетной записи ELK
}
    
```

#### Опционально ручные действие: установка OPA Gatekeeper (helm)
В случае, если вы предпочитаете OPA Gatekeeper вместо Kyverno то выставите значение `kyverno_enabled` - *false* при вызове модуля и выполните установку вручную
- Установите OPA Gatekeeper [с помощью helm](https://open-policy-agent.github.io/gatekeeper/website/docs/install/#deploying-via-helm)
- Выберите и установить необходимые constraint template и constraint из [gatekeeper-library](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy) 
- [Пример установки](https://github.com/open-policy-agent/gatekeeper-library#usage)
