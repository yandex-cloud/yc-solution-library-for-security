# Пример установки cluster WAF PTAF (Positive Tech. WAF) в Yandex.Cloud 


## Описание:
В рамках workshop будут выполнены:
- установка инфраструктуры с помощью terraform (infrastructure as a code)
- инсталяция и базовая конфигурация PTAF cluster в 2-х зонах доступности Yandex.Cloud

## Сценарий окружения:
Предполагается, что в Yandex.Cloud уже развернут небезопасный сценарий: ВМ с веб приложениями в 2-х зонах доступности. Также внешний сетевой балансировщик нагрузки. 


## Схема до:




## Схема после:



## Подготовка/Пререквизиты:
- установить и настроить [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- установить [terraform](https://www.terraform.io/downloads.html)
- скачать архив с файлами "..zip"


## Развертывание terraform:
- перейти в папку с файлами
- вставить необходимые параметры в файле variables.tf (в комментариях указаны необходимые команды yc для получения значений)
- выполнить команду инициализации terraform

```
terraform init

```
- выполнить команду импорта load-balancer

```
terraform import yandex_lb_network_load_balancer.ext-lb $(yc load-balancer network-load-balancer list --format=json | jq '.[].id' | sed 's/"//g') 
```

- выполнить команду запуска terraform
```
terraform apply
```

## Развертывание ручные действия:
- включить NAT на subnet: ext-subnet-a, ext-subnet-b (для того, чтобы PTAF мог выходить в интернет за обновлениями и др.)
- назначить Security Group "app-sg" на ВМ: app-a, app-b


## Описание шагов работы с PTAF:
