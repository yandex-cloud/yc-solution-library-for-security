# Identity Provider в Yandex Cloud на основе Keycloak 

Предоставление доступа корпоративным пользователям к облачным ресурсам Yandex Cloud реализуется с помощью сервиса [организации](https://cloud.yandex.ru/docs/organization/) и его дочернего объекта - [федерации удостоверений](https://cloud.yandex.ru/docs/organization/add-federation). Федерации удостоверений реализуют функциональность Single Sign On (SSO). Такие решения называются Identity Provider (idP). В Yandex Cloud поддерживаются федерации удостоверений на базе [SAML v2.0](https://wiki.oasis-open.org/security). 

В простейшем случае SSO сценарий может выглядеть так:
1. Пользователь вводит в браузере адрес облачной консоли Yandex Cloud с указанием идентификатора федерации
2. Облачная консоль Yandex Cloud перенаправляет запрос пользователя на страницу корпоративной системы SSO, которая предлагает пользователю аутентифицироваться (ввести свои имя и пароль).
3. Корпоративная система SSO, проверяет введенные пользователем данные и в случае успешной их проверки возвращает пользователя в консоль Yandex Cloud уже аутентифицированным. Авторизация (проверка полномочий) для пользователя выполняется на стороне Yandex Cloud.
4. Пользователю в браузере показывается его каталог с облачными ресурсами куда у него есть доступ.

## Компоненты решения
* Организация с настроенной федерацией удостоверений в Yandex Cloud
* MDB PostgreSQL Instance для хранения данных Keycloak 
* Виртуальная машина с развернутым Keycloak (java приложение)
* Браузер пользователя

## Входные данные
Все входные данные описываются в [variables.tf](./variables.tf). Этот файл используется как **Source of Truth (SoT)** для Terraform и сопутствующих bash скриптов (*.sh). 

`Важное замечание`. Cкрипты на bash продолжаем использовать, потому что функциональное покрытие публичного Terraform провайдера Yandex Cloud недостаточно (в yc сейчас есть гораздо больше). В данном сценарии TF провайдер не поддерживет работу с сертификатами Let's Encrypt и загрузку SSL сертификатов для федерации удостоверений. В качестве костыля в Terraform можно использовать **null_resource**, пример можно посмотреть в [federation.tf](./federation.tf).

## Environment
```bash
yc config profile activate sale
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export TF_VAR_cloud_id=$YC_CLOUD_ID
export TF_VAR_org_id=$(yc organization-manager organization list --format=json | jq -r '.[] .id')
#export TF_VAR_folder_id=$YC_FOLDER_ID
```

## Порядок действий (вносятся изменения!)
0. `Внимание!` Перед началом выполнения работ следует убедиться, что в сервисе Cloud DNS рабочей папки (cloud folder) `уже создана публичная DNS-зона` с которой будем работать дальше. Имя этой зоны далее указывается в переменной **dns_zone_name** (см. ниже).
1. Заполняем все входные данные в файле [variables.tf](./variables.tf)
2. Запускаем [kc-users-gen.sh](./kc-users-gen.sh) - получаем файл со списком учетных записей пользователей федерации с автогенерированными паролями. Имя файла в переменной `kc_user_file`.
3. Запускаем [kc-le-cert.sh](./kc-le-cert.sh) - получаем Let's Encrypt сертификаты для нужного домена в виде пары .pem файлов. Имена файлов в переменных `le_cert_pub_key` и `le_cert_priv_key` соответственно.
4. `terraform apply` делает всё остальное. ВМ с Keycloak после создания сильно конфигурируется через provisioners: file и remote-exec. Подробности на bash [здесь](./kc-setup.sh). 
5. Создание пользовательских ресурсов, выдача role bindings, sa и список ролей к ним - [user-resources.tf](./user-resources.tf) - в процессе осмысления...
