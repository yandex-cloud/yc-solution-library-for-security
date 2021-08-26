# Шифрование диска ВМ в Облаке с помощью YC KMS

## Описание
Решение позволяет выполнять шифрование диска [Yandex Compute Cloud ВМ](https://cloud.yandex.ru/services/compute) с помощью [Yandex Key Management Service](https://cloud.yandex.ru/services/kms) и [dm-crypt](https://en.wikipedia.org/wiki/Dm-crypt)

## Описание работы скрипта
Скрипт имеет входные аргументы (cases):
- create: Скрипт выполняет создание ключа с высокой энтропией методом KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey)
- open: Монтирование зашифрованного диска в расшифрованный объект
- close: Размонтирование зашифрованного устройства
- erase: Удаление исходного устройства
Рекомендуется хранить ключ шифрования "ENCRYPTED_DEK_FILE" в защищенном удаленном месте, например [Yandex Object Storage](https://cloud.yandex.ru/services/storage)

```
aws s3 cp encrypted1_dek.enc s3://<bucket-name>/encrypted1_dek.enc
```

## Подготовка/Пререквизиты:
- установить на ВМ [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- создать сервисную УЗ
- создать ключ KMS
- назначить права на ключ KMS созданному сервисному аккаунту (kms.keys.encrypterDecrypter)
- создать Object Storage Bucket
- назначить права на Object Storage bucket созданному сервисному аккаунту (storage.uploader, storage.viewer + BucketPolicy)
- назначить на ВМ сервисную УЗ
- установить aws cli (apt install awscli)
- установить cryptsetup (apt install cryptsetup-bin)

Посомтреть названия дисков возможно с помощью команды:

```
lsblk
```

## Итоги развертывания

https://cloud.yandex.ru/docs/compute/operations/vm-control/vm-attach-disk 

Статус cryptsetup
```
cryptsetup status encrypted1
```


делаем тераформ:
-создаем все прериквизиты
-клауд инит:
  -устанавливаем все что нужно
  -создаем файл aws-creds
  -передаем все нужные енвы