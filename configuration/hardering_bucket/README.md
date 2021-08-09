## Пример безопасной конфигурации Yandex Cloud Object Storage: Terraform

#### Описание 
Terraform скрипт выполняет следующее:
- [x] Создает [Bucket](https://cloud.yandex.ru/docs/storage/concepts/bucket)
- [x] Выполняет разграничение доступа ([IAM](https://cloud.yandex.ru/docs/storage/security/), [BucketPolicy](https://cloud.yandex.ru/docs/storage/concepts/policy)) для групп: администраторы, read-only, write-only
- [x] Включает [версионирование](https://cloud.yandex.ru/docs/storage/concepts/versioning) и [жизненный цикл](https://cloud.yandex.ru/docs/storage/concepts/lifecycles) так, чтобы: хранить текущие версии файлов 365 дней, НЕтекущие версии файлов (удаленные/измененные) 150 дней
- [x] Включает [логирование](https://cloud.yandex.ru/docs/storage/operations/buckets/enable-logging) действий над Bucket в отдельный Bucket
- [x] Включает [шифрование](https://cloud.yandex.ru/docs/storage/operations/buckets/encrypt) (Server-Side) объектов в Bucket 

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
  description = "Yandex Cloud security OAuth token"
  default     = "/Users/mirtov8/Documents/key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "b1g35l8msdsaf20p5iue" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b1gkmtuljp4d2k3g5aph" #yc config get cloud-id
}

//----------------------------------------------------------------

variable "all-access-users" {
  description = ""
  default = ["federatedUser:ajesnkfkc77lbh50isvg", "federatedUser:ajeurmedn87ekpuc4e08"]

}

variable "read-only-sa" {
  description = ""
  default = ["serviceAccount:ajeph8f8d7pp4j0cbprj", "serviceAccount:aje066sl8m1e7ci508bl"]

}

variable "write-only-sa" {
  description = "sa"
  default = ["serviceAccount:ajem3ef72rr9hhe5kso6", "serviceAccount:aje1ngf44k7nceombinn"]

}
```
