# Развертывание и управление организацией и правами доступа через IaC terraform 

**Version:1.0**

# Описание
Задача: Полное управление организацией через terraform. На каждый проект должно выделяться одно облако с назначенной группой ответственных администраторов за облако. Должно быть отдельное облако security со своей ответственной группой админов. В каждом облаке отдельное управление через TF. Нарезаются dev, non-prod, prod каталоги с разными правами. Управление уровнем организации должно происходить в одном tf state через git, а управление уровнем облаков в своих собственных state также через git.

**Summary**:
- Существует организация
- В организации есть первый bootstrap владелец с правами "organization-manager.organizations.owner" (после bootstrap он не используется)
- Руками создается первое облако "cloud-org-admin"
- В облаке создается каталог и сервисный аккаунт с правами "organization-manager.admin" и "resource-manager.admin" на уровне организации. 
- Далее под этим сервисным аккаунтом создается 1-ый org-level terraform state
- Создаются организационные сущности: saml федерация, группы для администраторов облаков, облака и биндинги групп
- В облаке "cloud-org-admin" также опционально создается IDP Keycloak и наполняется пользователями для входа через федерацию удостоверений
- В облаке security создается sa и audit trails для мониторинга всех событий иб уровня облака с организации
- Далее админы своих облаков создают собственные state terraform с конфигурацией их облаков
- Все управление tf происходит через git подход. Каждое изменение (PR) должны проверять ответственные за tf соответствующего уровня

# Схема и скриншот результата
![iam_iac-IaC1 drawio](https://user-images.githubusercontent.com/85429798/197990571-07edcc7b-83ee-441b-9bc3-2c839d72c37c.png)

![iam_iac-Multifolder VPC drilldown drawio](https://user-images.githubusercontent.com/85429798/197990607-34cd21ef-fbf0-457e-8e1e-4e9e285a93ff.png)

<img width="1049" alt="скрин" src="https://user-images.githubusercontent.com/85429798/197990620-6f99b158-eece-477c-8d22-3fa0e015ed96.png">


# Инструкция:
**Пререквизиты**:
- Платежный аккаунт yandex cloud
- Созданная организация
- Если выбрана установка keycloak то необходимо иметь публичную зону dns [делегированнную в yandex cloud](https://cloud.yandex.ru/docs/dns/operations/zone-create-public)

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
7) Перейдите в папку ./module_keycloak . Запускаем kc-users-gen.sh - получаем файл со списком учетных записей пользователей федерации с автогенерированными паролями. Имя файла в переменной kc_user_file.
8) Укажите переменные dns_zone_name, folder_id и kc_fqdn согласно вашим значениям в файле module_keycloak/variables.tf . Это необходимо для генерации сертификата.
9) Запускаем kc-le-cert.sh - получаем Let's Encrypt сертификаты для нужного домена в виде пары .pem файлов. Имена файлов в переменных le_cert_pub_key и le_cert_priv_key соответственно из папки module_keycloak/variables.tf 
10) Вернитесь в исходную общую папку. Заполните файл terraform.tfvars !не забудьте поменять имя файла на terraform.tfvars
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

14) Запустить terraform init, terraform plan, terraform apply

15) Ссылка в консоль UI в созданную федерацию и на idp keycloak будет в output 

15) Зайдите в облако security в каталог cloud_admin и создайте Audit Trails согласно [инструкции](https://cloud.yandex.ru/docs/audit-trails/quickstart) с записью в S3 бакет используя сервисный аккаунт предсозданный . Используйте это [решение для создания безопасного s3 бакета](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/configuration/hardening_bucket)

16) Не забудьте подключить s3 remote storage для terraform по [инструкции](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/terraform-sec/remote-backend). Также информация есть в [вебинаре](https://www.youtube.com/watch?v=XJDLcx8UWUU)

17) Также строго рекомендуется поместить tf конфиг в защищенный git репозиторий и управлять выкаткой изменений в state с помощью PR и согласования

18) Передайте ответственному администратору за облако "web-app-project" его логин/пароль и ссылку на вход в федерацию из output вида "https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m" . Ответственный администратор назначается в группе "web-admin-group-members" в файле org_level_groups_and_users.tf

**Уровень облаков**
1)  Войдите в UI консоль под ответственным администратором за облако "web-app-project" с помощью ссылки в output, например https://console.cloud.yandex.ru/federations/bpf3pc05joidt9it7l0m
2) Настройте yc cli под федеративным пользователем, которого вам выдали согласно [инструкции](https://cloud.yandex.ru/docs/cli/operations/authentication/federated-user)
3) Создайте новый каталог "network-folder" (уберите галочку создать сеть по умолчанию)
```Python
yc resource-manager folder create --name network-folder
```
4) Создайте в нем сервисный аккаунт "sa-web-app-tf" 
```Python
yc iam service-account create --name sa-web-app-tf --folder-name network-folder
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
6) В основном каталоге данного решения и раскомментируйте строки в файле org_level_grant_viewer.tf (начиная со строки номер 3). Затем запустите еще раз terraform plan, terraform apply. Этим вы предоставите сервисной учетной записи sa-web-app-tf роль organization-manager.viewer (необходимо для доступа к данным по группам).
7) Скачайте репозиторий по аналогии с п. 0 организационного уровня выше. Перейдите в папку "/cloud-level-state"
8) Создайте авторизованный ключ
```Python
yc iam key create --service-account-name sa-web-app-tf --output sa-key.json  
```
9) Вернитесь в каталог /cloud-level-state. Заполните файл terraform.tfvars своими значениями 
10) Запустите terraform init, terraform plan, terraform apply
11) Установите managed gitlab в каталоге network-folder и поместите туда terraform config и credentials от sa sa-web-app-tf




