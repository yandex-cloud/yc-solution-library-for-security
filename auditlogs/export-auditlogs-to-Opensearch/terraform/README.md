## Развертывание примера через Terraform

По результатам выполнения tf скрипта и ручных действий указанных ниже, в указанный вами opensearch будут загружаться события audit trails из облака и будет загружен security content (dashboard, filters, mapping etc.)

1) Скачайте репозиторий:
```
git clone https://github.com/yandex-cloud/yc-solution-library-for-security.git

cd перейти в папку решения auditlogs/export-auditlogs-to-Opensearch/terraform
```

2) Создайте сервисный аккаунт для тераформ или используйте токен. Если используете sa то скачайте ключ 

```
yc iam service-account create --name my-sa

yc iam key create --service-account-name my-sa --output key.json
```

3) Заполните файл tfvars.tf (он по сути заполняет `variables.tf`) значениями для: 
- opensearch_pass
- opensearch_user
- opensearch_dashboard_address вида "https://c-c9qct655ceh02mhabb4i.rw.mdb.yandexcloud.net"
- opensearch_node_address вида "https://rc1a-xxx.mdb.yandexcloud.net"
- folder_id
- cloud_id
- token (тут указать путь до файла ключа sa , по умолчанию key.json)
- subnet_id (указать айди подсети в которой надо развернуть вм перекладчика, должна иметь доступ к opensearch)


4) Для заполнения поля token создайте [ключ](https://cloud.yandex.ru/docs/iam/operations/authorized-key/create) для сервисного аккаунта для аутентификации в terraform либо используйте ваш OAuth токен yc
5) Запустите:

```
terraform init
terraform apply
```

Terraform модуль создает следующий набор объектов в Yandex.Cloud:
2) Сервисный аккаунт с ролью `storage.admin` для создания бакета в Object Storage
2.1) Статический ключ для сервисного аккаунта
2.2) S3 бакет
3) Сервисный аккаунт с правами `storage.editor` для дальнейшей работы с бакетом
5) Контейнер и COI-инстанс из модуля для загрузки событий и контента

По окончанию установки необходимо развернуть сервис [AuditTrails](https://cloud.yandex.ru/docs/audit-trails/quickstart) через консоль Yandex.Cloud, создать сервисную учетную запись по инструкции, и указать созданный модулем бакет. 

> **Важно:** Необходимо указать пустой префикс для бакета, либо изменить префикс в вызове в файле `main.tf`.

> **Важно:** Необходимо включить NAT на созданных подсетях.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | ~> 0.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | ~> 0.60 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_yc-opensearch-trail"></a> [yc-opensearch-trail](#module\_yc-opensearch-trail) | ./modules/yc-opensearch-trail/ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [yandex_iam_service_account.sa-bucket-creator](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account.sa-bucket-editor](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account_static_access_key.sa-bucket-creator-sk](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_resourcemanager_folder_iam_binding.storage_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_binding) | resource |
| [yandex_resourcemanager_folder_iam_binding.storage_editor](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_binding) | resource |
| [yandex_storage_bucket.trail-bucket](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | Yandex.Cloud ID where resources will be created | `string` | `"xxxxxx"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Yandex.Cloud Folder ID where resources will be created | `string` | `"xxxxxx"` | no |
| <a name="input_opensearch_dashboard_address"></a> [opensearch\_dashboard\_address](#input\_opensearch\_dashboard\_address) | FQDN-адрес инсталляции Opensearch вида https://c-xxx.rw.mdb.yandexcloud.net | `string` | `""` | no |
| <a name="input_opensearch_node_address"></a> [opensearch\_node\_address](#input\_opensearch\_node\_address) | FQDN-адрес инсталляции Opensearch вида https://rc1a-xxx.mdb.yandexcloud.net | `string` | `""` | no |
| <a name="input_opensearch_pass"></a> [opensearch\_pass](#input\_opensearch\_pass) | Пароль для аутентификации в Opensearch | `string` | `""` | no |
| <a name="input_opensearch_user"></a> [opensearch\_user](#input\_opensearch\_user) | Пользователь для аутентификации в Opensearch | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet\_id where you need to place your coi\_instance. Need to connect to Opensearch host | `string` | `""` | no |
| <a name="input_token"></a> [token](#input\_token) | Yandex.Cloud security OAuth token либо ключ сервисного аккаунта | `string` | `"key.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket-for-trails"></a> [bucket-for-trails](#output\_bucket-for-trails) | ## Outputs |
<!-- END_TF_DOCS -->