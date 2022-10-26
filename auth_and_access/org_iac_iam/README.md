# Развертывание и управление организацией и правами доступа через IaC terraform 

# Описание

Задача: Полное управление организацией через terraform. На каждый проект должно выделяться одно облако с назначенной группой ответственных администраторов за облако. Должно быть отдельное облако security со своей ответственной группой админов. В каждом облаке отдельное управление через TF. Нарезаются dev, non-prod, prod каталоги с разными правами. Управление уровнем организации должно происходить в одном tf state через git, а управление уровнем облаков в своих собственных state также через git.

**Summary**:
- Существует организация
- В организации есть первый bootstrap владелец с правами "organization-manager.organizations.owner" (после bootstrap он не используется)
- Руками создается первое облако "cloud-org-admin"
- В облаке создается каталог и сервисный аккаунт с правами "organization-manager.admin" и "resource-manager.admin" на уровне организации. 
- Далее под этим сервисным аккаунтом создается 1-ый org-level terrafrom state
- Создаются организационные сущности: saml федерация, группы для администраторов облаков, облака и биндинги групп
- В облаке "cloud-org-admin" также опционально создается IDP Keycloak и наполняется пользователями для входа через федерацию удостоверений
- В облаке security создается sa и audit trails для мониторинга всех событий иб уровня облака с организации
- Далее админы своих облаков создают собственные state terraform с конфигурацией их облаков
- Все управление tf происходит через git подход. Каждое изменение (PR) должны проверять ответственные за tf соответствующего уровня

# Схема и скриншот результата
![iam_iac-IaC1 drawio](https://user-images.githubusercontent.com/85429798/197990571-07edcc7b-83ee-441b-9bc3-2c839d72c37c.png)

![iam_iac-Multifolder VPC drilldown drawio](https://user-images.githubusercontent.com/85429798/197990607-34cd21ef-fbf0-457e-8e1e-4e9e285a93ff.png)

<img width="1049" alt="скрин" src="https://user-images.githubusercontent.com/85429798/197990620-6f99b158-eece-477c-8d22-3fa0e015ed96.png">


# Инстуркция:
**Пререквизиты**:
- Платежный аккаунт yandex cloud
- Созданная организация

**Уровень организации**
1) Настроить yc cli 
2) Создать руками первое облако cloud-org-admin
3) Создать в нем каталог org-admin
4) Создать руками sa sa-org-admin для управления tf в этом каталоге
5) Убедиться, что в сервисе Cloud DNS папки org-admin уже создана публичная DNS-зона с которой будем работать дальше. Имя этой зоны далее указывается в переменной DNS_ZONE_NAME
6) Запускаем kc-users-gen.sh - получаем файл со списком учетных записей пользователей федерации с автогенерированными паролями. Имя файла в переменной kc_user_file.
7) Укажите переменные dns_zone_name, folder_id и kc_fqdn согласно вашим значениям в файле module_keycloak/variables.tf . Это необходимо для генерации сертификата.
8) Запускаем kc-le-cert.sh - получаем Let's Encrypt сертификаты для нужного домена в виде пары .pem файлов. Имена файлов в переменных le_cert_pub_key и le_cert_priv_key соответственно из папки module_keycloak/variables.tf 
9) Заполните файл terraform.tfvars:
- BA_ID биллинг аккаунт id 
- ORG_ID org_id
- KEYCLOAK keycloak true/false
- ORG_ADMIN_FOLDER_ID folder-id каталога org-admin
- ORG_ADMIN_CLOUD_ID
- DNS_ZONE_NAME
- KC_FQDN
- CLOUD-1-NAME
- CLOUD-2-NAME

10) Выдать права sa на оргу через cli (пока не поддержана возможность выдачи через UI)

```Python
yc organization-manager organization add-access-binding \
  --role organization-manager.admin \
  --id bpf4c0lctf2t734l95ui \
  --service-account-name sa-org-admin

yc organization-manager organization add-access-binding \
  --role resource-manager.admin \
  --id bpf4c0lctf2t734l95ui \
  --service-account-name sa-org-admin

yc organization-manager organization add-access-binding \
  --role viewer \
  --id bpf4c0lctf2t734l95ui \
  --service-account-name sa-org-admin

```

11) Создать ключ для sa-org-admin 
```Python
yc iam key create --service-account-name sa-org-admin --output sa-key.json  

```

12) Заполните terraform.tfvars своими значениями

12) Запустить terrafrom init, terrafrom plan, terraform apply

13) Ссылка в консоль UI в созданную федерацию и на idp keycloak будет в output 

14) Зайдите в облако security в каталог cloud_admin и создайте Audit Trails согласно [инструкции](https://cloud.yandex.ru/docs/audit-trails/quickstart) с записью в S3 бакет используя сервисный аккаунт предсозданный . Используйте это [решение для создания безопасного s3 бакета](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/configuration/hardening_bucket)

15) Не забудьте подключить s3 remote storage для terraform по [инструкции](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/terraform-sec/remote-backend). Также информация есть в [вебинаре](https://www.youtube.com/watch?v=XJDLcx8UWUU)

16) Также строго рекомендуется поместить tf конфиг в защищенный git репозиторий и управлять выкаткой изменений в state с помощью PR и согласования

17) Передайте ответственному администратору за облако "web-app-project" его логин/пароль и ссылку на вход в федерацию из output вида "https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m" . Ответственный администратор назначается в группе "web-admin-group-members" в файле org_level_groups_and_users.tf

**Уровень облаков**
1)  Войдите в UI консоль под ответственным администратором за облако "web-app-project" с помощью ссылки в output, например https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m
2) Создайте новый каталог "network-folder" (уберите галочку создать сеть по умолчанию)
3) Создайте в нем сервисный аккаунт "sa-web-app-tf" и выдайте при создании в ui права "resource-manager.admin" и "viewer" именно на облако
4) Перейдите в папку "cloud-level-state"
5) Настройте yc cli под федеративным пользователем, которого вам выдали согласно [инстуркции](https://cloud.yandex.ru/docs/cli/operations/authentication/federated-user)
6) Создайте авторизованный ключ
```Python
yc iam key create --service-account-name sa-web-app-tf --output sa-key.json  
```
7) Заполните файл terraform.tfvars своими значениями 
8) добавьте sa-web-app-tf в org levbel tf с правами organization-manager.viewer, чтобы он мог получать инфомрацию про группы 
9) Запустите terraform init, terraform plan, terrafrom apply
10) Установите managed gitlab в каталоге network-folder и поместите туда terrafrom config и credentials от sa sa-web-app-tf




