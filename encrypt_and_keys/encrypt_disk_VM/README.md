# Шифрование диска ВМ в Облаке с помощью YC KMS

## Описание
- Решение позволяет выполнять шифрование диска [Yandex Compute Cloud ВМ](https://cloud.yandex.ru/services/compute) с помощью [Yandex Key Management Service](https://cloud.yandex.ru/services/kms) и [dm-crypt](https://en.wikipedia.org/wiki/Dm-crypt)
- Развертывание ВМ и пререквизитов выполняется с помощью примера terraform скрипта 

## Описание работы решения
- В cloud-init скрипт при развертывания ВМ передаюися необходимые данные
- Устанавливаются ПО: awscli, cryptsetup-bin, curl
- Передается созданный terraform ssh ключ
- Выполняется bash скрипт с аргументом create: создается ключ шифрования с высокой энтропией методом KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey) и записывается на диск: в открытом и зашифрованном виде 
- Шифруется и монтируется второй диск ВМ на основе ключа шифрования
- Ключ шифрования в зашифрованном виде копируется в[Yandex Object Storage](https://cloud.yandex.ru/services/storage) и удаляется из файловой системы
- Скрипт с аргументом open добавляется в автозагрузку ОС (чтобы при перезагрузке автоматически примонтировать шифрованный диск)
- В момент монтирования ключ шифрования скачивается из S3, расшифровывается и по окончанию мониторования удаляется из файловой системы

P.S: все операции с KMS и ObjectStorage выполняются с помощью токена сервисного аккаунта, привязанного к ВМ при создании

Описание аргументов скрипта:
- create: Скрипт выполняет создание ключа с высокой энтропией методом KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey)
- open: Монтирование зашифрованного диска в расшифрованный объект
- close: Размонтирование зашифрованного устройства
- erase: Удаление исходного устройства


## Схема работы


## Пререквизиты (устанавливаются с помощью примера Terraform скрипта):
- установить на ВМ [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- создать сервисную УЗ
- создать ключ KMS
- назначить права на ключ KMS созданному сервисному аккаунту (kms.keys.encrypterDecrypter)
- создать Object Storage Bucket
- назначить права на Object Storage bucket созданному сервисному аккаунту (storage.uploader, storage.viewer + BucketPolicy)
- назначить на ВМ сервисную УЗ
- установить aws cli (apt install awscli)
- установить cryptsetup (apt install cryptsetup-bin)


## Запуск решения
- Скачайте файлы
- Заполните файл variables.tf
- Выполните команды terraform:

```
terraform init
terraform apply
```
## Итоги развертывания

Вставить все скрины


подпись про снэпшот и проверку


