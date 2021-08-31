## Тестовый скрипт terraform 


1) Заполните файл variables2.tf
2) Запустите:

```
terraform init
terraform apply
```

Модуль выполнит следующие действия:
1) Создает подсеть для cluster managed k8s
2) Создает cluster managed k8s
3) Создает Сервисный аккаунт, который может писать в бакет и имеет роль ymq.admin
4) Создает Object Storage Bucket
5) Создает Subnet для развертывания ВМ (не забыть включить NAT руками)
6) Вызывает 2 модуля
