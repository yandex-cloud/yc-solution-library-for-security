## Пример безопасной конфигурации Yandex Cloud Object Storage: Terraform

#### Схема решения
![Схема](https://user-images.githubusercontent.com/85429798/136698539-f7772475-cca7-4498-8c79-426fc385a90f.png)


#### Описание 
Terraform скрипт выполняет следующее:
- :white_check_mark: Создает [Bucket](https://cloud.yandex.ru/docs/storage/concepts/bucket)
- :white_check_mark: Выполняет разграничение доступа ([IAM](https://cloud.yandex.ru/docs/storage/security/), [BucketPolicy](https://cloud.yandex.ru/docs/storage/concepts/policy)) для групп: администраторы, read-only, write-only
- :white_check_mark: Включает [версионирование](https://cloud.yandex.ru/docs/storage/concepts/versioning) и [жизненный цикл](https://cloud.yandex.ru/docs/storage/concepts/lifecycles) так, чтобы: хранить текущие версии файлов 365 дней, НЕтекущие версии файлов (удаленные/измененные) 150 дней
- :white_check_mark: Включает [логирование](https://cloud.yandex.ru/docs/storage/operations/buckets/enable-logging) действий над Bucket в отдельный Bucket
- :white_check_mark: Включает [шифрование](https://cloud.yandex.ru/docs/storage/operations/buckets/encrypt) (Server-Side) объектов в Bucket 

#### Terraform детали 
Решение принимает на вход (variables):
- список учетных записей администраторов: all-access-users
- список сервисных аккаунтов, требущих прав чтения: read-only-sa
- список сервисных аккаунтов, требущих прав записи: write-only-sa

Выполняет:
- Создание sa с правами storage admin для создания Bucket
- Создание KMS ключа для шифрования
- Назначение прав учетным записям на работу с KMS ключами
- Назначение прав IAM учетным записям для работы с Bucket
- Создание отдельного Bucket для логирования действий 
- Создание основного Bucket
- Применение BucketPolicy 
- Включение версионирования и жизненного цикла
- Включение логирования
- Включение шифрования

#### Пример заполнения variables:
```Python
variable "token" {
  description = "Yandex.Cloud security OAuth token"
  default     = "key.json" # generate yours: https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID where resources will be created"
  default     = "xxxxxx" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID where resources will be created"
  default     = "xxxxxx" #yc config get cloud-id
}

variable "all-access-users" {
  description = ""
  default = ["federatedUser:ajesnkfkxxxxxxxxxxxx", "federatedUser:ajeurmedxxxxxxxxxxxx"]

}

variable "read-only-sa" {
  description = ""
  default = ["serviceAccount:ajeph8f8xxxxxxxxxxxx", "serviceAccount:aje066slxxxxxxxxxxxx"]

}

variable "write-only-sa" {
  description = "sa"
  default = ["serviceAccount:ajem3ef7xxxxxxxxxxxx", "serviceAccount:aje1ngf4xxxxxxxxxxxx"]

}
```
