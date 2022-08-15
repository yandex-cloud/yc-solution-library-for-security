## Развертывание примера через Terraform

По результатам выполнения tf скрипта и ручных действий указанных ниже, в указанный вами opensearch будут загружаться события audit trails из облака и будет загружен security content (dashboard, filters, mapping etc.)

1) Заполните файл `variables.tf` значениями для: opensearch_pass, opensearch_user, opensearch_address, folder_id, cloud_id, token
2) Для заполнения поля token создайте [ключ](https://cloud.yandex.ru/docs/iam/operations/authorized-key/create) для сервисного аккаунта для аутентификации в terraform либо используйте ваш OAuth токен yc
3) Запустите:

```
terraform init
terraform apply
```

Terraform модуль создает следующий набор объектов в Yandex.Cloud:
1) Сеть VPC с тремя подсетями (по одной в каждой из зон доступности)
2) Сервисный аккаунт с ролью `storage.admin` для создания бакета в Object Storage
2.1) Статический ключ для сервисного аккаунта
2.2) S3 бакет
3) Сервисный аккаунт с правами `storage.editor` для дальнейшей работы с бакетом
5) Контейнер и COI-инстанс из модуля для загрузки событий и контента

По окончанию установки необходимо развернуть сервис [AuditTrails](https://cloud.yandex.ru/docs/audit-trails/quickstart) через консоль Yandex.Cloud, создать сервисную учетную запись по инструкции, и указать созданный модулем бакет. 

> **Важно:** Необходимо указать пустой префикс для бакета, либо изменить префикс в вызове в файле `main.tf`.

> **Важно:** Необходимо включить NAT на созданных подсетях.