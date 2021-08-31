# Удаление стенда

Аутентифицируемся от имени профиля default в terraform и yc:

```
export YC_TOKEN=$(yc iam create-token --profile default)
```
Удалим кластер Kubernetes:

```
$ cd ../terraform/staging/
$ terraform destroy
```

Удалим роли:

```
$ cd ../iam

terraform destroy
```

Удалим сервисные аккаунты:

```
$ yc iam service-account delete --name devops-user1 --folder-id=$STAGING_FOLDER_ID --profile default
$ yc iam service-account delete --name developer-user1 --folder-id=$STAGING_FOLDER_ID --profile default
```

