# Развертывание и управление организацией и правами доступа через IaC terraform 

**Version:1.1**

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

<img width="1264" alt="image" src="https://user-images.githubusercontent.com/85429798/198960106-ae3663a0-0054-4504-93da-3fbe1682ebc5.png">

<img width="1919" alt="image" src="https://user-images.githubusercontent.com/85429798/198960141-f0dec470-590c-4ae8-8661-9ef448dc39eb.png">

<img width="1049" alt="скрин" src="https://user-images.githubusercontent.com/85429798/197990620-6f99b158-eece-477c-8d22-3fa0e015ed96.png">


# Инстуркция:
**Пререквизиты**:
- Платежный аккаунт yandex cloud
- Созданная организация
- Если выбрана установка keycloaс то необходимо иметь публичную зону dns [делегированнную в yandex cloud](https://cloud.yandex.ru/docs/dns/operations/zone-create-public)

**Уровень организации**
0) Скачайте репозиторий и перейдите в папку
```Python
git clone https://github.com/yandex-cloud/yc-solution-library-for-security.git
cd yc-solution-library-for-security/auth_and_access/org_iac_iam
```
1) Настроить [yc cli](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi49oiWr4L7AhXLl4sKHSOnCxQQFnoECBkQAQ&url=https%3A%2F%2Fcloud.yandex.ru%2Fdocs%2Fcli%2Fquickstart&usg=AOvVaw3sNw2joYtjNX6fJJHB-EP8)
2) Создать руками первое облако cloud-org-admin
3) Укажите в yc cli ваше первое облако 
```Python
yc config set cloud-id <id облака>
```
4) Создать в нем каталог org-admin (без default сети)
```Python
yc resource-manager folder create --name org-admin
```
5) Создать руками sa sa-org-admin для управления tf в этом каталоге
```Python
yc iam service-account create --name sa-org-admin --folder-name org-admin
```
6) Убедиться, что в сервисе Cloud DNS папки org-admin уже [создана публичная DNS-зона](https://cloud.yandex.ru/docs/dns/operations/zone-create-public) с которой будем работать дальше. Имя этой зоны далее указывается в переменной DNS_ZONE_NAME
8) Перейдите в папку ./module_keycloak. Укажите переменные dns_zone_name, folder_id и kc_fqdn согласно вашим значениям в файле module_keycloak/variables.tf . Это необходимо для генерации сертификата.
9) Запускаем kc-le-cert.sh - получаем Let's Encrypt сертификаты для нужного домена в виде пары .pem файлов. Имена файлов в переменных le_cert_pub_key и le_cert_priv_key соответственно из папки module_keycloak/variables.tf 
10) Вернитесь в исходную общую папку. Заполните файл terraform.tfvars !не забудьте поменять имя файла на terrafrom.tfvars
11) Выдать права sa на оргу через cli (пока не поддержана возможность выдачи через UI)

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

12) Создать ключ для sa-org-admin 
```Python
yc iam key create --service-account-name sa-org-admin --output sa-key.json  

```

13) Заполните terraform.tfvars своими значениями

14) Запустить terrafrom init, terrafrom plan, terraform apply

15) Ссылка в консоль UI в созданную федерацию и на idp keycloak будет в output 

15) Зайдите в облако security в каталог cloud_admin и создайте Audit Trails согласно [инструкции](https://cloud.yandex.ru/docs/audit-trails/quickstart) с записью в S3 бакет используя сервисный аккаунт предсозданный . Используйте это [решение для создания безопасного s3 бакета](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/configuration/hardening_bucket)

16) Не забудьте подключить s3 remote storage для terraform по [инструкции](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/terraform-sec/remote-backend). Также информация есть в [вебинаре](https://www.youtube.com/watch?v=XJDLcx8UWUU)

17) Также строго рекомендуется поместить tf конфиг в защищенный git репозиторий и управлять выкаткой изменений в state с помощью PR и согласования

18) Сгенерированные логины и пароли администраторов находятся в файле ./moudle_keycloak/kc-users.lst . Не забудьте настроить keycloak, чтобы он требовал смену пароля при первом входе.

18) Передайте ответственному администратору за облако "web-app-project" его логин/пароль и ссылку на вход в федерацию из output вида "https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m" . Ответственный администратор назначается в группе "web-admin-group-members" в файле org_level_groups_and_users.tf

19) Пример output:
```Python
Outputs:

federation_id = "bpfi9ahu438i1171r654"
federation_link = "https://console.cloud.yandex.ru/federations/bpfi9ahu438i1171r654"
keycloak_links = "https://kc.lavre.link:8443"
```

**Уровень облаков**
1)  Войдите в UI консоль под ответственным администратором за облако "web-app-project" с помощью ссылки в output, например https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m
2) Настройте yc cli под федеративным пользователем, которого вам выдали согласно [инстуркции](https://cloud.yandex.ru/docs/cli/operations/authentication/federated-user)
4) Создайте в нем сервисный аккаунт "sa-web-app-tf" 
```Python
yc iam service-account create --name sa-web-app-tf --folder-name network
```
5) Выдайте ему права "resource-manager.admin" и "viewer" **именно на облако web-app-project**, а не на каталог
```Python
yc resource-manager cloud add-access-binding \
  --role resource-manager.admin \
  --id <ваш cloud id> \
  --service-account-name sa-web-app-tf 

yc resource-manager cloud add-access-binding \
  --role viewer \
  --id <ваш cloud id> \
  --service-account-name sa-web-app-tf 

```

6) Скачайте репозиторий по аналогии с п. 0 организационного уровня выше. Перейдите в папку "/cloud-level-state"
7) Создайте авторизованный ключ
```Python
yc iam key create --service-account-name sa-web-app-tf --output sa-key.json  
```
8) Заполните файл terraform.tfvars своими значениями 
9) Добавляйте при необходимости обьекты tf 
10) Запустите terraform init, terraform plan, terrafrom apply
11) Установите managed gitlab в каталоге network-folder и поместите туда terrafrom config и credentials от sa sa-web-app-tf, чтобы управлять IaC


---
# Документация "terraform-docs" org_level


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.0 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.81.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_keycloak"></a> [keycloak](#module\_keycloak) | ./module_keycloak | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.kc-users-lst](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_60_seconds2](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [yandex_iam_service_account.sec-sa-trail](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_organizationmanager_group.cloud-admins-group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.dev-folder-groups-cloud1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.dev-folder-groups-cloud2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.network-folder-groups-cloud1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.network-folder-groups-cloud2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.nonprod-folder-groups-cloud1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.nonprod-folder-groups-cloud2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.prod-folder-groups-cloud1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group.prod-folder-groups-cloud2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group) | resource |
| [yandex_organizationmanager_group_membership.admin-group-members](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_group_membership) | resource |
| [yandex_organizationmanager_organization_iam_member.trails-bind-sa](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_organization_iam_member) | resource |
| [yandex_resourcemanager_cloud.create-clouds](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud) | resource |
| [yandex_resourcemanager_cloud_iam_member.admin-binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.cloud-viewer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.compute-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.dns-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.mdb-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.storageadmin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.viewer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_cloud_iam_member.vpc-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) | resource |
| [yandex_resourcemanager_folder.cloud_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder) | resource |
| [yandex_resourcemanager_folder.first-folders](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder) | resource |
| [yandex_resourcemanager_folder.second-folders](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder) | resource |
| [yandex_resourcemanager_folder_iam_member.dev1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.dev1-1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.dev1-2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.dev2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.network1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.network1-1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.network2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.network2-2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod1-1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod1-2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod1-3](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.nonprod3](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod1-1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod1-2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod1-3](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.prod3](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_iam_service_account.sa-org-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_service_account) | data source |
| [yandex_organizationmanager_saml_federation_user_account.user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/organizationmanager_saml_federation_user_account) | data source |
| [yandex_resourcemanager_cloud.cloud-org-admin](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/resourcemanager_cloud) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_BA_ID"></a> [BA\_ID](#input\_BA\_ID) | billing account id | `string` | `""` | no |
| <a name="input_CLOUD-LIST"></a> [CLOUD-LIST](#input\_CLOUD-LIST) | List of Organization-level groups with their Roles | <pre>list(object(<br>    {<br>      name = string,<br>      descr = string,<br>      admin = string,<br>      folders = list(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "admin": "user1@example.com",<br>    "descr": "web-app cloud",<br>    "folders": [<br>      "network",<br>      "prod",<br>      "nonprod",<br>      "dev"<br>    ],<br>    "name": "web-app"<br>  },<br>  {<br>    "admin": "user2@example.com",<br>    "descr": "mobile-app cloud",<br>    "folders": [<br>      "network",<br>      "prod",<br>      "nonprod",<br>      "dev"<br>    ],<br>    "name": "mobile-app"<br>  },<br>  {<br>    "admin": "user3@example.com",<br>    "descr": "security cloud",<br>    "folders": [<br>      ""<br>    ],<br>    "name": "security"<br>  }<br>]</pre> | no |
| <a name="input_DEV-CLOUD_GROUPS"></a> [DEV-CLOUD\_GROUPS](#input\_DEV-CLOUD\_GROUPS) | List of Groups that you want to pre-create for your clouds | <pre>list(object(<br>    {<br>      name = string,<br>      descr = string,<br>      roles = list(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "descr": "network dev",<br>    "name": "dev-network",<br>    "roles": [<br>      "vpc.admin",<br>      "monitoring.admin"<br>    ]<br>  },<br>  {<br>    "descr": "dev devops",<br>    "name": "dev-devops",<br>    "roles": [<br>      "k8s.admin",<br>      "container-registry.admin",<br>      "alb.admin",<br>      "k8s.cluster-api.cluster-admin",<br>      "vpc.user",<br>      "iam.serviceAccounts.user"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_DNS_ZONE_NAME"></a> [DNS\_ZONE\_NAME](#input\_DNS\_ZONE\_NAME) | name of dns zone in yandex cloud, not dns name | `string` | `""` | no |
| <a name="input_KC_FQDN"></a> [KC\_FQDN](#input\_KC\_FQDN) | dns name of keycloak | `string` | `""` | no |
| <a name="input_KEYCLOAK"></a> [KEYCLOAK](#input\_KEYCLOAK) | install keycloak or no | `string` | `""` | no |
| <a name="input_NETWORK-CLOUD_GROUPS"></a> [NETWORK-CLOUD\_GROUPS](#input\_NETWORK-CLOUD\_GROUPS) | List of Groups that you want to pre-create for your clouds | <pre>list(object(<br>    {<br>      name = string,<br>      descr = string,<br>      roles = list(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "descr": "admin who can view and monitor network",<br>    "name": "network-viewer",<br>    "roles": [<br>      "vpc.viewer",<br>      "monitoring.admin"<br>    ]<br>  },<br>  {<br>    "descr": "admin who can administrate gitlab",<br>    "name": "gitlab-admin",<br>    "roles": [<br>      "gitlab.admin"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_NONPROD-CLOUD_GROUPS"></a> [NONPROD-CLOUD\_GROUPS](#input\_NONPROD-CLOUD\_GROUPS) | List of Groups that you want to pre-create for your clouds | <pre>list(object(<br>    {<br>      name = string,<br>      descr = string,<br>      roles = list(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "descr": "devops nonprod",<br>    "name": "nonprod-devops",<br>    "roles": [<br>      "k8s.editor",<br>      "container-registry.editor",<br>      "alb.editor",<br>      "k8s.cluster-api.editor",<br>      "vpc.user",<br>      "load-balancer.admin"<br>    ]<br>  },<br>  {<br>    "descr": "sre nonprod",<br>    "name": "nonprod-sre",<br>    "roles": [<br>      "compute.operator",<br>      "loadtesting.editor",<br>      "storage.editor",<br>      "alb.editor"<br>    ]<br>  },<br>  {<br>    "descr": "dba nonprod",<br>    "name": "nonprod-dba",<br>    "roles": [<br>      "mdb.admin",<br>      "ydb.editor"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_ORG_ADMIN_CLOUD_ID"></a> [ORG\_ADMIN\_CLOUD\_ID](#input\_ORG\_ADMIN\_CLOUD\_ID) | cloud\_id of first cloud | `string` | `""` | no |
| <a name="input_ORG_ADMIN_FOLDER_ID"></a> [ORG\_ADMIN\_FOLDER\_ID](#input\_ORG\_ADMIN\_FOLDER\_ID) | folder\_id of first folder in org cloud | `string` | `""` | no |
| <a name="input_ORG_ID"></a> [ORG\_ID](#input\_ORG\_ID) | organization id | `string` | `""` | no |
| <a name="input_PROD-CLOUD_GROUPS"></a> [PROD-CLOUD\_GROUPS](#input\_PROD-CLOUD\_GROUPS) | List of Groups that you want to pre-create for your clouds | <pre>list(object(<br>    {<br>      name = string,<br>      descr = string,<br>      roles = list(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "descr": "devops prod",<br>    "name": "prod-devops",<br>    "roles": [<br>      "k8s.viewer",<br>      "container-registry.viewer",<br>      "alb.viewer",<br>      "k8s.cluster-api.viewer",<br>      "vpc.user",<br>      "load-balancer.viewer"<br>    ]<br>  },<br>  {<br>    "descr": "sre prod",<br>    "name": "prod-sre",<br>    "roles": [<br>      "compute.viewer",<br>      "loadtesting.viewer",<br>      "storage.configViewer",<br>      "alb.viewer"<br>    ]<br>  },<br>  {<br>    "descr": "dba prod",<br>    "name": "prod-dba",<br>    "roles": [<br>      "mdb.viewer",<br>      "ydb.viewer"<br>    ]<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_federation_id"></a> [federation\_id](#output\_federation\_id) | n/a |
| <a name="output_federation_link"></a> [federation\_link](#output\_federation\_link) | n/a |
| <a name="output_keycloak_links"></a> [keycloak\_links](#output\_keycloak\_links) | n/a |
<!-- END_TF_DOCS -->
