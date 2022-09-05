# Yandex Cloud Lockbox password solution.

Сценарий для развертывания IdP KeyCloak с хранением и получением пар логин/пароль в Yandex Cloud Lockbox.

# Проблематика
При запуске KeyCloak на ВМ как сервис, в конфигурацию /lib/systemd/system/keycloak.service необходимо прописывать логин и пароль в базе данных и логин с паролем администратора в явном виде.
При обычном развертывании таких сценариев, приходится передавать секреты в user-data так же в явном виде.

# Решение
Назначенный на виртуальную машину сервисный аккаунт может аутентифицироваться и авторизоваться в IAM изнутри гостевой ОС по упрощенной схеме. Т.е. достаточно просто получить IAM-токен через yc cli или REST API, не передавая никакой информации о субъекте. Это дает возможность при минимально необходимых правах безопасно передать в гостевую ОС пару ключ/значение (секретная часть) из Lockbox с помощью сервисного аккаунта.

Безопасная конфигурация
<img width="441" alt="solution_schema" src="https://user-images.githubusercontent.com/85429798/188415570-30edb050-03f4-47be-9ac8-9bab52968288.png">

1. Сервисный аккаунт обращается к секрету Lockbox через REST
2. Lockbox проверяет права на секрет и на ключ, расшифровывает секрет
3. В гостевую ОС возвращается JSON с секретом

После применения сценария развертывания скрипт удаляет все промежуточные файлы с секретами и удаляет сервисный аккаунт.

# Настройка окружения

Предполагаем, что у вас уже есть доступ в Yandex Cloud, вы знаете идентификатор своего облака (`cloud-id`) и [идентификатор каталога](https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id) (`folder-id`) в вашем облаке где будут создаваться облачные ресурсы.

## Установка YC CLI
Для развёртывания рабочего окружения установим инструмент `Yandex Cloud CLI (yc)` на свой компьютер (подробная [инструкция](https://cloud.yandex.ru/docs/cli/operations/install-cli#interactive)).

## Установка git
Для загрузки рецепта Terraform установите git [по инструкции](https://git-scm.com/book/ru/v2/Введение-Установка-Git).
 
## Установка Terraform
Установите инструмент `Terraform` на свой компьютер (если он уже не установлен) по [(инструкции)](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform).

  ### Установка Terraform для Windows:
  Распакуйте архив и скопируйте файл terraform.exe в каталог `C:\Windows\System32`
 
Для корректной установки всех необходимых ресурсов Terraform создайте в домашнем каталоге (`/home/<username>` - для MacOS и Linux, `C:\Users\Administrator\AppData\Roaming`- для Windows) файл `.terraformrc` (для Windows `terraform.rc`) с содержимым:

```bash
provider_installation {
    network_mirror {
      url = "https://terraform-mirror.yandexcloud.net/"
      include = ["registry.terraform.io/*/*"]
    }
    direct {
      exclude = ["registry.terraform.io/*/*"]
    }
  }
```

## Подключение к Web консоли облака
* [Подключение к Web консоли облака с помощью Яндекс ID (Option A)](#yandex-id)
* [Подключение к Web консоли облака с помощью Федерации удостоверений сервиса Организации (Option B)](#federation-id)

### Подключение к Web консоли облака с помощью Яндекс ID (Option A)
* Откроем в новой вкладке браузера [консоль облака](https://console.cloud.yandex.ru/) и, слева внизу, выберем `Учетная запись` и выйдем из всех текущих аккаунтов облака. В результате на экране должна показаться страница с кнопкой `Войти в аккаунт на Яндексе`. Закроем эту страницу.
* Откроем в новой вкладке [ссылку](https://passport.yandex.ru/auth?mode=add-user&retpath=https%3A%2F%2Fconsole.cloud.yandex.ru%2F) где будет предложено авторизоваться в Яндекс ID
* Введём имя и пароль пользователя для учётной записи Яндекс ID, после чего произойдёт перенаправление в консоль Yandex Cloud
* Перейдём по [ссылке](https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb) для получения OAuth Token. Значение token будет выглядеть примерно так `AQAAAAAABQ0pAATrwPdubkJPerC4mJyaRELWbUY`
* Сохраним полученное значение Token в переменной окружения (для Windows – PowerShell, MacOS и Linux – bash)

#### Windows:
```PowerShell
$env:YC_TOKEN="<ваш OAuth Token>"
```

#### MacOS и Linux:
```bash
export YC_TOKEN=<ваш OAuth Token>
```

Создадим профиль в yc для работы с облаком

#### Настройка профиля yc в MacOS и Linux:
```bash
yc config profile create lockbox
yc config set cloud-id <cloud-id>
yc config set folder-id <folder-id>
yc config set token $YC_TOKEN
```

#### Настройка профиля yc в Windows:
```PowerShell
yc config profile create lockbox
yc config set cloud-id <cloud-id>
yc config set folder-id <folder-id>
yc config set token $env:YC_TOKEN
```

где вместо `<cloud-id>` нужно указать идентификатор своего облака, а вместо `<folder-id>` нужно указать идентификатор каталога в облаке. Идентификаторы можно получить из консоли облака через веб интерфейс.

### Подключение к Web консоли облака с помощью Федерации удостоверений сервиса Организации (Option B)

* Создадим профиль в `yc` для работы с облаком
  ```bash
  yc config profile create lockbox
  yc config set cloud-id <cloud-id>
  yc config set folder-id <folder-id>
  yc config set federation-id <federation-id>
  ```
  где вместо \<cloud-id\> нужно указать идентификатор своего облака, например, `b1g8d7gjpvedf23hg3sv`, вместо \<folder-id\> нужно указать идентификатор каталога в облаке, например, `b1guv7crr32qfgiimxwp`, а вместо \<federation-id\> нужно указать идентификатор федерации, например, `yc.your-org-name.federation`. Идентификаторы можно получить из консоли облака через веб интерфейс в разделе сервиса Organizations.
 
### Загрузка сценария Terraform
```bash
git clone https://github.com/Sayanaro/YandexCloud-Security-Course-KeyCloackVersion.git
cd YandexCloud-Security-Course-KeyCloackVersion
```
 
## Развёртывание рабочей среды с помощью Terraform

Имена виртуальных машин, домена, и пользователей задаются переменными в файле `terraform.tfvars`. Остальные переменные заданы в файле `variables.tf` в параметрах по умолчанию.

Для начала зададим переменные окружения:
 
### Еслим вы используете учетную запись Яндекс ID:

#### Windows:
 
* Запустите консоль PowerShell
* Выполните:
```PowerShell
yc config profile activate security
$env:YC_TOKEN = "ваш OAuth токен"
$env:YC_CLOUD_ID=$(yc config get cloud-id)
$env:YC_FOLDER_ID=$(yc config get folder-id)
```

#### MacOS/Linux:
 
* Запустите консоль bash
* Выполните:
```bash
yc config profile activate security
export YC_TOKEN="ваш OAuth токен"
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

### Еслим вы используете федеративную учетную запись:

#### Windows:
 
* Запустите консоль PowerShell
* Выполните:
```PowerShell
yc config profile activate security
$env:YC_TOKEN = $(yc iam create token)
$env:YC_CLOUD_ID=$(yc config get cloud-id)
$env:YC_FOLDER_ID=$(yc config get folder-id)
```

#### MacOS/Linux:
 
* Запустите консоль bash
* Выполните:
```bash
yc config profile activate security
export YC_TOKEN=$(yc iam create token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

### Проброс переменных окружения в переменные Terraform:

В ходе работы сценарию потребуется передать folder-id и cloud-id. Для этого эти значения нужно передать в переменные окружения Terraform.
Для обоих сценариев аутентификации:

#### Windows:

```PowerShell
$env:TF_VAR_CLOUDID = $env:YC_CLOUD_ID
$env:TF_VAR_CLOUDID = $env:YC_FOLDER_ID
```

#### MacOS/Linux:

```bash
export TF_VAR_CLOUDID=$YC_CLOUD_ID
export TF_VAR_FOLDERID=$YC_FOLDER_ID
```

### Инициализация и старт сценария

Инициализируйте Terraform:
```bash
terraform init
terraform apply
```

Сценарий попросит ввести 2 пароля: администратора и администратора базы данных PostgreSQL. Паролb должны быть не менее 8 символов, содержать строчные и заглавные буквы, минимум одну цифру 0-9 и минимум один спецсимвол (@#$%&*/:;"'\,.?+=-_).

Спустя 4 минуты сервер будет настроен и готов к работе.

## Подключение к ВМ
```bash
# keycloak:
ssh ubuntu@<keycloak_vm_public_ip> -i pt_key.pem
