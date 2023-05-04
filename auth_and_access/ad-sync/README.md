# Yandex Cloud синхронизация пользователей и групп.

## Synopsis
Сценарий получает список пользователей в указанных группах LDAP-каталога, проверяет наличе группы. Если группа не существует - сценарий создаст ее. Далее проверяется наличе федеративных пользователей. Если пользователя не существует - сценарий его создаст, указав в качестве NameID либо UserPrincipalName, либо Mail (в зависимости от маппинга со стороны IdP). После чего, контроллируется члество в группе. Если пользователь был исключен из группы в LDAP-каталоге, сценарий исключит его из группы в облаке.
Контроль членства идет по пользователям конкретной федерации. В случае исключения пользователя, аккаунты других федераций и аккаунты Yandex Passport затронуты не будут.

# v.0.1
## Органичения:
* Имена групп должны использовать символы латиницы и символ "-". Другие символы в т.ч. пробелы не допускаются
* Запуск скрипта должен выполняться в контексте Domain User LDAP-каталога (пользователь должен быть членом домена)
* Создание групп только при наличии привелегии organization.Admin

# Описание ключей
- `GroupNames` - массив имен групп LDAP-каталога. Задается через @() или ""
- `YCToken` - [уникальная последовательность символов, которая выдается пользователю после прохождения аутентификации. С помощью этого токена пользователь авторизуется в API Yandex Cloud и выполняет операции с ресурсами.](https://cloud.yandex.ru/docs/iam/concepts/authorization/iam-token)
- `YCOrgID` - идентификатор организации Yandex Cloud.
- `FederationName` - имя федерации в организации Yandex Cloud.
- `LoginType` - атрибут учетной записи пользоваться, которая будет маппиться в NameID. Возможные значения: `UPN` и `Mail`. Значение по умолчанию: `UPN`.
- `LogDirectory` - путь к каталогу для логов. По умолчанию используется текущий каталог, где расположен скрипт.

<{ 
# Настройка окружения

Предполагаем, что у вас уже есть доступ в Yandex Cloud, вы знаете идентификатор своей организации (`organization-id`) и имя федерации, где будут создаваться пользователи.

## Установка YC CLI
Для развёртывания рабочего окружения установим инструмент `Yandex Cloud CLI (yc)` на свой компьютер (подробная [инструкция](https://cloud.yandex.ru/docs/cli/operations/install-cli#interactive)).

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
$env:YCToken="<ваш OAuth Token>"
```

Создадим профиль в yc для работы с облаком

#### Настройка профиля yc в Windows:
```PowerShell
yc config profile create lockbox
yc config set cloud-id <cloud-id>
yc config set folder-id <folder-id>
yc config set token $env:YCToken
```

где вместо `<cloud-id>` нужно указать идентификатор своего облака, а вместо `<folder-id>` нужно указать идентификатор каталога в облаке. Идентификаторы можно получить из консоли облака через веб интерфейс.

### Подключение к Web консоли облака с помощью Федерации удостоверений сервиса Организации (Option B)

* Создадим профиль в `yc` для работы с облаком
  ```bash
  yc config profile create lockbox
  yc config set cloud-id <cloud-id>
  yc config set folder-id <folder-id>
  yc config set federation-id <federation-id>
  yc config set organization-id <federation-id>
  ```
  где вместо \<cloud-id\> нужно указать идентификатор своего облака, например, `b1g8d7gjpvedf23hg3sv`, вместо \<folder-id\> нужно указать идентификатор каталога в облаке, например, `b1guv7crr32qfgiimxwp`, а вместо \<federation-id\> нужно указать идентификатор федерации, например, `yc.your-org-name.federation`. Идентификаторы можно получить из консоли облака через веб интерфейс в разделе сервиса Organizations.}>

# Запуск сценария

Для начала зададим переменные окружения:

#### Windows:
 
* Запустите консоль PowerShell
* Выполните:
```PowerShell
yc config profile activate iam
$env:YCToken= $(yc iam create token)
$env:YC_CLOUD_ID=$(yc config get cloud-id)
$env:YC_FOLDER_ID=$(yc config get folder-id)
$env:YC_ORG=$(yc config get organization-id)
```

## Пример 1

```PowerSHell
> .\Sync-YCLDAPUsers.ps1 -GroupNames @("group1","Group2") -YCToken $env:YCToken -YCOrgID $env:YC_ORG FederationName = "dev-federation" -LoginType UPN
```

Команда создает и синхронизирует членов группы group1 and Group2 в указанной организации и федерации, используя в качестве NameID атрибут UserPrincipalName.

## Пример 2

```PowerShell
$Params = @{
        GroupNames = @("group1","Group2")
        YCToken = $env:YCToken
        YCOrgID = $env:YC_ORG
        FederationName = "dev-federation"
        LoginType = "Mail"
    }  
    
.\Sync-YCLDAPUsers.ps1 @Params
```

Команда создает и синхронизирует членов группы group1 and Group2 в указанной организации и федерации, используя в качестве NameID атрибут Mail.
