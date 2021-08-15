# Отказоустойчивая эксплуатация PT Application Firewall на базе Yandex.Cloud
Цель демо: Установка PT Web Application Firewall (далее PT WAF) в Yandex.Cloud в отказоустойчивой конфигурации.

## Подробный разбор workshop на видео:
[![image](https://user-images.githubusercontent.com/85429798/129480863-ef468a52-1191-4a23-9801-5e09c0de0cad.png)](https://www.youtube.com/watch?v=tnGuyIXNL6o)


## Содержание:
- Описание
- Развертывание
- Описание шагов работы с PT WAF
- Проверка прохождения траффика и отказоустойчивости
- Дполнительные материалы: настройка кластеризации PT WAF и настройка Yandex Application LoadBalancer 

## Описание:
В рамках workshop будут выполнены:
- установка инфраструктуры с помощью terraform (infrastructure as a code)
- инсталяция и базовая конфигурация PT WAF cluster в 2-х зонах доступности Yandex.Cloud

Отказоучстойчивость обеспечивается за счет:
- кластеризации самих PT WAF в режиме active-active
- балансировки траффика с помощью External-LB Yandex.Cloud
- cloud-finction Yandex.Cloud, которая отслеживает состояние PT WAF и в случаи их падения направляет траффик на приложения напрямую - "BYPASS"

#### Сценарий окружения:
Предполагается, что в Yandex.Cloud у Клиента уже развернут небезопасный сценарий публикации ВМ наружу: ВМ с веб приложениями в 2-х зонах доступности. Также внешний сетевой балансировщик нагрузки. 

*для установки целой схемы снуля необходимо использовать playbook из папки "from-scratch"

#### Схема до:
![image](https://user-images.githubusercontent.com/85429798/127995744-e9213d79-6fca-49cd-a2bf-3cf7bead0c75.png)





#### Схема после:
![image](https://user-images.githubusercontent.com/85429798/127995787-9d547d0c-390c-4df7-8577-928607fb3d08.png)

![image](https://user-images.githubusercontent.com/85429798/127995819-fdc647d8-9125-4acf-8708-4088b8c28826.png)





## Подготовка/Пререквизиты:
- установить и настроить [yc client](https://cloud.yandex.ru/docs/cli/quickstart)
- установить [terraform](https://www.terraform.io/downloads.html)
- установить [jq](https://macappstore.org/jq/)

## Развертывание

#### Развертывание terraform:

- скачать архив с файлами [pt_archive.zip](https://github.com/yandex-cloud/yc-architect-solution-library/blob/main/security-solution-library/unmng-waf-ptaf-cluster/main/pt_archive.zip)
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
- включить NAT на subnet: ext-subnet-a, ext-subnet-b (для того, чтобы PT WAF мог выходить в интернет за обновлениями и активировать лицензию)
- назначить Security Group "app-sg" на ВМ: app-a, app-b

[<img width="1135" alt="image" src="https://user-images.githubusercontent.com/85429798/126979165-eb4c9e6b-806d-401c-bec1-53f54cbecef1.png">](https://www.youtube.com/watch?v=IOYw4fdn69A)

##

## Описание шагов работы с PT AF
Видеоинструкция этапа:

- пробрасываем порты по SSH для подключения к серверам PT AF (ВЫПОЛНЯЕМ В 2 РАЗНЫХ ОКНАХ ТЕРМИНАЛА):
```
ssh -L 22001:192.168.2.10:22013 -L 22002:172.18.0.10:22013 -L 8443:192.168.2.10:8443 -L 127.0.0.2:8443:172.18.0.10:8443 -i ./pt_key.pem yc-user@$(yc compute instance list --format=json | jq '.[] | select( .name == "ssh-a")| .network_interfaces[0].primary_v4_address.one_to_one_nat.address '| sed 's/"//g') 
```
после этого вы окажитесь в терминале ssh-a (брокер машина) оставте его открытым

## Настройка кластеризации PT AF 

### Настройка master-сервера
- подключитесь к ptaf-a: 
```
ssh -p 22001 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
```
- выпишите текущий пароль БД:
```
sudo wsc -c 'password list'  
```
- выполните скрипт автоконфигурации кластера: 
```
/home/pt/cluster.sh
```
### Настройка slave-сервера
- подключитесь к ptaf-b: 
```
ssh -p 22002 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
```
- задайте пароль БД из прошлого этапа
```
sudo wsc -c 'password set <мастер-пароль>' (должен совпадать с тем, который задан на узле master). 
```
- выполните скрипт автоконфигурации кластера: 
```
/home/pt/cluster.sh
```
#### Создание кластера

- сначала запустим синхронизацию на SLAVE-сервере использовав команду:
```
ssh -p 22002 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
sudo wsc
Enter 0 
config commit
```
- дождитесь когда на SLAVE-сервере появится сообщение: "TASK: [mongo | please configure all other nodes of your cluster]". после этого  переключитесь на MASTER-сервер и начните синхронизацию той же командой:
```
ssh -p 22001 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
sudo wsc
Enter 0 
config commit
```
*в случае, если на MASTER config commit завершится неуспешно, применть команду еще раз

- далее конфигурация на узле master остановилась на сообщении TASK: [mongo | wait config sync on secondary nodes], просто вручную выполните команду config sync на узле SLAVE.

- на SLAVE выполнить:
```
config sync 
```
- на Master выполнить:
```
config sync
```
- на Master выполнить:
```
mongo --authenticationDatabase admin -u root -p $(cat /opt/waf/conf/master_password) waf --eval 'c = db.sentinel; l = c.findOne({_id: "license"}); Object.keys(l).forEach(function(k) { if (l[k].ip) { delete l[k].ip; l[k].hostname = "yclicense.ptsecurity.ru" }}); c.update({_id: l._id}, l)'
```

[<img width="1041" alt="image" src="https://user-images.githubusercontent.com/85429798/127007705-3a727cec-07c9-4071-80ca-1631070f83f2.png">](https://www.youtube.com/watch?v=zuTxyEeM7Vg)


#### Настройка обработки траффика

- Открываем в браузере https://127.0.0.1:8443 

- Вводим стандартные логин и пароль, admin/positive ,меняем пароль, например на P@ssw0rd

- Открываем вкладку Configuration->Network->Gateways, кликая на иконку карандаша(Edit) 
- в каждом из шлюзе устанавливаем галочку Active
- в каждом из шлюзе на вкладке Network определяем для интерфейса eth-ext1 алиасы mgmt,wan,lan

- Создаем апстрим на вкладке Configuration->Network->Upstreams
- Name: internal-lb
- Backend Host: впишите адрес внутреннего балансировщика яндекс облако
- Backend port: 80

- Создаем сервис на вкладке Configuration->Network->Services
- Name: app
- Net interface alias: wan
- Listen port: 80
- Upstream: internal-lb

- Редактуируем существующее веб приложение 'Any' на вкладке Configuration -> Security -> Web Applications:
- Service: app


[![image](https://user-images.githubusercontent.com/85429798/127023351-f0731361-5ba5-429a-82e9-5cc3c14a6355.png)](https://www.youtube.com/watch?v=lCFnHanCSSE)


## Проверка прохождения траффика и отказоустойчивости
- посмотрите внешний ip адреса внешнего балансировщика нагрузки
- отклюим ptaf-a и убедимся, что траффик проходит
- отключим app-a и убедимся, что траффик проходит
- отклюим ptaf-b и убедимся, что BYPASS сработает и траффик переключится напрямую на внутренний балансировщик
- включите ptaf-a, ptaf-b обратно и убедитесь то, что траффик снова идет через ptaf

[![image](https://user-images.githubusercontent.com/85429798/127031813-f9460c50-2765-40d4-aa16-f66fc7fd70b7.png)](https://www.youtube.com/watch?v=DQYzXVKVVjg)



## Дополнительные материалы


## Настройка Yandex Application LoadBalancer 

В данной схеме возможно использовать [Application LoadBalancer Yandex.Cloud](https://cloud.yandex.ru/docs/application-load-balancer/)

Существует подробная инструкция по [Организация виртуального хостинга](https://cloud.yandex.ru/docs/application-load-balancer/solutions/virtual-hosting)
(включая интеграцию с certificate manager для управления SSL сертификатами)

