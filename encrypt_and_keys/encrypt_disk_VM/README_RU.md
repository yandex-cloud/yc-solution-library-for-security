# Шифрование диска ВМ в Облаке с помощью YC KMS

## Описание
- Решение позволяет выполнять шифрование диска (кроме загрузочного) [Yandex Compute Cloud ВМ](https://cloud.yandex.ru/services/compute) с помощью [Yandex Key Management Service](https://cloud.yandex.ru/services/kms) и [dm-crypt](https://en.wikipedia.org/wiki/Dm-crypt)+[LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup)
- Развертывание решения и пререквизитов выполняется с помощью примера terraform скрипта 

## Схема работы
![Схема](https://user-images.githubusercontent.com/85429798/131116794-8dd100e3-c024-4297-a39d-8d1482fc8ead.png)


## Описание работы решения
- В [cloud-init](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata#keys-processed-in-public-images) скрипт при развертывания ВМ передатися необходимые данные
- Устанавливается ПО: awscli, cryptsetup-bin, curl
- Передается созданный terraform ssh ключ
- На ВМ выполняется bash скрипт с аргументом create: создается ключ шифрования с высокой энтропией методом KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey) и записывается на диск в открытом и зашифрованном виде 
- Шифруется и монтируется второй диск ВМ на основе ключа шифрования
- Ключ в зашифрованном виде копируется в [Yandex Object Storage](https://cloud.yandex.ru/services/storage) и удаляется из файловой системы
- Скрипт с аргументом open добавляется в автозагрузку ОС (чтобы при перезагрузке автоматически примонтировать шифрованный диск)
- В момент монтирования ключ шифрования скачивается из S3, расшифровывается и по окончанию мониторования удаляется из файловой системы

> Все операции с KMS и Object Storage выполняются с помощью токена сервисного аккаунта, привязанного к ВМ при ее создании

Описание аргументов скрипта:
- create: Скрипт выполняет создание ключа с высокой энтропией методом KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey)
- open: Монтирование зашифрованного диска в расшифрованный объект
- close: Размонтирование зашифрованного устройства
- erase: Удаление исходного устройства


## Пререквизиты (настраиваются с помощью примера Terraform скрипта):
- установить на ВМ [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- создать сервисную УЗ
- создать ключ KMS
- назначить права на ключ KMS созданному сервисному аккаунту (kms.keys.encrypterDecrypter)
- создать Object Storage Bucket
- назначить права на Object Storage bucket созданному сервисному аккаунту (storage.uploader, storage.viewer + BucketPolicy)
- назначить на ВМ сервисную УЗ
- установить aws cli (`apt install awscli`)
- установить cryptsetup (`apt install cryptsetup-bin`)


## Запуск решения
- Скачайте файлы
- Заполните файл variables.tf
- Выполните команды terraform:

```
terraform init
terraform apply
```
## Итоги развертывания
- Проверить статус примонтированных объектов:

```
lsblk
```

![Статус](https://user-images.githubusercontent.com/85429798/131117114-d15f733e-8db8-4bdc-a3bf-082554a4e7cc.jpg)

- Проверить статус шифрования диска:

```
cryptsetup status encrypted1
```
![Статус](https://user-images.githubusercontent.com/85429798/131117237-bb081d75-3876-4970-9a2c-b52ae4161c55.jpg)

- Проверить диск на другой ВМ: Создать snapshot диска:

![Снапшот](https://user-images.githubusercontent.com/85429798/131117342-0ef73d39-890b-49c4-888c-7ca43789356f.jpg)

- Создать ВМ с диском из snapshot:
![Создание ВМ](https://user-images.githubusercontent.com/85429798/131117386-e1e9e805-2412-48bd-be9e-41e4ee83eed9.png)

- Попробовать примонтировать диск:

```
sudo mount /dev/vdb /mnt
```
![Результат теста](https://user-images.githubusercontent.com/85429798/131117495-c2cc85d4-21c9-4578-9027-907bf6c9d0c2.jpg)
