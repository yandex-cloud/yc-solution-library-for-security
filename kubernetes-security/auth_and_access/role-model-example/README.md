# Пример настройки ролевых моделей и политик в Managed Service for Kubernetes®

# Подробный разбор на видео
[![image](https://user-images.githubusercontent.com/85429798/130356018-0840545a-da13-4faa-b15d-2858e3a9e369.png)](https://www.youtube.com/watch?v=ot6I_wmkLr4&t=1597s)


# Стенд для для практического вебинара по Kubernetes

Видео стенда будет доступно после публикации на Youtube
Стенд позволяет самостоятельно настроить все, что было показано в вебинаре. В частности

1) Ролевую модель управления к разным контейнерным средам
2) Политики запуска подов в созданном кластере


## Пререквизиты

- bash
- terraform
- jq
- [cli](https://cloud.yandex.ru/docs/cli/operations/install-cli), инициированный в профиле default а вашего пользователя( он должен быть admin или editor на уровне облака)
- Два тестовых фолдера. Их ID понадобятся ниже
- helm v3

## Подготовка окружения

Стенд будет состоять из двух фолдеров и двух пользователей devops и developer. 


Запишем ID фолдеров для нашей задач

```
export STAGING_FOLDER_ID=<ID фолдера staging для демо>
export PROD_FOLDER_ID=<ID фолдера prod для демо>
```

Создадим сервисные аккаунты, которые будут эмулировать пользователей

```
$ yc iam service-account create --name devops-user1 --folder-id=$STAGING_FOLDER_ID
$ yc iam service-account create --name developer-user1 --folder-id=$STAGING_FOLDER_ID
```
Создадим два профиля для cli, один профиль будет эмулировать пользователя devops, второй developer
```
$ yc iam key create --service-account-name devops-user1 --folder-id=$STAGING_FOLDER_ID --output devops.json
$ yc iam key create --service-account-name developer-user1 --folder-id=$STAGING_FOLDER_ID --output developer.json

$ yc config profile create demo-devops-user1
$ yc config set service-account-key devops.json

$ yc config profile create demo-developer-user1
$ yc config set service-account-key developer.json
```
Проверим что в фолдерах для задания ни у кого пока нет никаких ролей
```
$ yc resource-manager folder list-access-bindings --id=$STAGING_FOLDER_ID --profile=default

+---------+--------------+------------+
| ROLE ID | SUBJECT TYPE | SUBJECT ID |
+---------+--------------+------------+
+---------+--------------+------------+

$ yc resource-manager folder list-access-bindings --id=$PROD_FOLDER_ID --profile=default

+---------+--------------+------------+
| ROLE ID | SUBJECT TYPE | SUBJECT ID |
+---------+--------------+------------+
+---------+--------------+------------+
```

Переходим к лабе

#### Часть первая - настройка ролевого доступа 

```
$ cd ./terraform/iam
```

И изучаем readme [данного раздела](./terraform/iam/)

#### Часть вторая - настройка политик

( Требует чтобы вы прошли часть 1 , или ранее созданного кластера kubernetes )

```
$ cd ./kubernetes/
```

И изучаем readme [данного раздела](./kubernetes/)

#### Часть третья удаляем стенд

```
$ cd ./end
```

И изучаем readme [данного раздела](./end/)

