# Шифрование секретов средствами KMS при передачи их в контейнер ВМ COI Yandex.Cloud: Terraform

## Проблематика
После развертывания контейнеров с помощью [Container Optimized Image (COI)](https://cloud.yandex.ru/docs/cos/concepts/) может возникнуть необходимость передать приватную информацию внутрь контейнера с помощью ENV.
Из UI консоли в данном случае, в свойствах ВМ будут видны передарнные ENV в открытом виде.
Возникает риск компрометации приватной информации.

Пример небезопасной конфигурации:

![image](https://user-images.githubusercontent.com/85429798/129485848-09fb4847-7ff6-46cd-be4a-990de7e41781.png)


## Пример безопасной передачи приватной информации в контейнер COI
Yandex Cloud KMS имеет возможность [шифрования секретов в Terraform](https://cloud.yandex.ru/docs/kms/solutions/terraform-secret)
Предлагается использовать данную функцию для передачи зашифрованных секретов в контейнер в виде ENV, с последующей расшифровкой изнутри python приложения.
Расшифровка секретов из python кода будет выполнена с помощью привязанного к ВМ COI сервисного аккаунта (с ролью KMS decrypter). Token сервисного аккаунта будет получен с помощью [сервиса мета-даты](https://cloud.yandex.ru/docs/compute/operations/vm-info/get-info#inside-instance). 

Terraform пример выполняет:
- развертывание тестовой инфраструктуры (сети, подсети)
- создание тестового service account и его статических ключей
- развертывание COI с контейнером на базе простого python приложения
- создание KMS ключа и шифрование приватных данных (в данном случае статических ключей сервисного аккаунта)
- приватные данные передаются в зашифрованном виде внутрь контейнера
- простое python приложение внутри кода расшифровывет приватные данные и делает print в лог

Важно* Данное решение не отменяет необходимости применения лучших практик защиты terraform конфигурации.
Yandex Cloud Object Storage может выступать в роли terraform remote state и выполнять функции блокировки с помощью Yandex Database - https://github.com/yandex-cloud/examples/tree/master/terraform-ydb-state 

## Подготовка/Пререквизиты:
- установить и настроить [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- установить [terraform](https://www.terraform.io/downloads.html)

## Итоги развертывания

В UI консоли мы видим секреты только в зашифрованном виде:

![image](https://user-images.githubusercontent.com/85429798/129485922-ceff4208-c562-4021-8cc3-ddf0f0d927ec.png)


В логах контейнера мы видим секреты в расшифрованном виде:

![image](https://user-images.githubusercontent.com/85429798/129485886-ca56bc93-4f86-45b1-ad99-c48de55bde6d.png)

