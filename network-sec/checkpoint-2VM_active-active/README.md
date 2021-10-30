# 2 NGFW Checkpoint: Active-Active



## Описание решения
Сегментация сети с помощью NGFW Checkpoint в двух зонах доступности (ДЦ) в режиме Active-Active

- Решение автоматически создает несколько сегментов сети в 2-х зонах доступности (ДЦ)
- Устанавливает/настраивает NGFW Checkpoint в кол-ве 2 шт. в режиме Active-Active, а также сервер управления
- При этом сетеая связь между зонами возможна и выполняется без ассиметрии
- В случае падения одного из 2-х FW - в этой зоне доступности сетевая связанность с интернетом и другими VPC пропадает
- Для кроссзональной связанности между VPC используется VPC Transit между 2-мя FW. Путь траффика из VPC Servers (zone A) в VPC Database (zone B) : servers-a -> FW-A -> FW-B -> database-b

## Что делает решение (детали)
- ☑️ Создает отдельные folder и vpc под каждый сегмент сети: "Servers", "Database", "Mgmt", (несколько "VPC-#" заглушек). Заглушки использованы по причине невозможности добавления дополнительных интерфейсов в ВМ в будущем. Названия VPC вы можете выбрать сами.
- ☑️ Создает сети и подсети для данных VPC в соответствии со схемой и заполненным файлом variables.tf
- ☑️ Создает необходимые облачные статические маршруты и назначает их на подсети VPC
- ☑️ Создает 2 ВМ FW: [Check Point CloudGuard IaaS - Firewall & Threat Prevention BYOL](https://cloud.yandex.ru/marketplace/products/f2eb527bqp4f4ksht2af) и 1 ВМ Сервер Управления: [Check Point CloudGuard IaaS - Security Management BYOL](https://cloud.yandex.ru/marketplace/products/f2e1si2qna6s0q01eda0). Оба образа имеют триал период. При использовании в прод для FW существует образ PAYG (с оплатой по факту использования), а для Сервера Управления необходимо приобрести лицензию отдельно от CheckPoint либо использовать свою on-prem license.
- ☑️ Выполняет настройку FW с помощью [cloud-config](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk165476) в соответствии со схемой (интерфейсы, маршруты, пароли). Благодаря этому нет необходимости проходить First time wizard.
- ☑️ Создает тестовую  windows машину для управления файрволами с помощью CheckPoint SMS.

## Пререквизиты
- :white_check_mark: должен быть аккаунт в облаке Yandex.Cloud
- :white_check_mark: установлен и настроен [yc cli](https://cloud.yandex.ru/docs/cli/quickstart)
- :white_check_mark: установлен и настроен git
- :white_check_mark: установлен [terraform](https://www.terraform.io/downloads.html)
- :white_check_mark: учетная запись облака с правами admin облака

## Развертывание с помощью Terraform
- скачайте все файлы и перейдите в папку
- заполните файл provider.tf вашим cloud_id и токеном (oauth токен либо файл-ключ сервисного аккаунта). Подробности [тут](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
- заполните файл variables.tf . Файл содержит default значения, но вы можете менять их своими данными (подсети, название vpc, название folder и др.). Обязательный параметр для смены - cloud_id. Пример:
```Python
//-------------For terrafrom

variable "cloud_id" {
  default     = "Your cloud id" #yc config get cloud-id
}
//------------VPC List
//--VPC 1
variable "vpc_name_1" {
  default     = "servers" #choose your name for vpc-1
}

variable "subnet-a_vpc_1" {
  default = "10.160.1.0/24" #change if you need
}
variable "subnet-b_vpc_1" {
  default = "10.161.1.0/24" #change if you need
}
//--VPC 2
variable "vpc_name_2" {
  default     = "database" #choose your name for vpc-2
}

variable "subnet-a_vpc_2" {
  default = "10.160.2.0/24" #change if you need
}
variable "subnet-b_vpc_2" {
  default = "10.161.2.0/24" #change if you need
}
```

- запустите команду:
```
terraform init
``` 
- запустите команду:
```
terraform apply
``` 

- по результатам вы получите outputs в консоли:

```Python
Outputs:

a-external_ip_address_of_win-check-vm = "193.32.218.131" # адрес windows ВМ для управления (зайдите скачайте через ui сервера управления gui консоль)
b-password-for-win-check = <sensitive> # пароль для win ВМ (для получения выполните "terraform output b-password-for-win-check")
c-ip_address_mgmt-server = "192.168.1.100" # адрес сервера управления
d-ui_console_mgmt-server_password = "admin" # пароль по умолчанию для ui сервера управления
e-gui_console_mgmt-server_password = <sensitive> # пароль для входа в gui консоль сервера управления ("terraform output e-gui_console_mgmt-server_password")
f-sic-password = <sensitive> # SIC пароль для связи между сервером управления и FW ("terraform output f-sic-password")
g-ip_address_fw-a = "192.168.1.10" # адрес FW-A
h-ip_address_fw-b = "192.168.2.10" # адрес FW-B
i-path_for_private_ssh_key = "./pt_key.pem" # SSH ключ для подключения к Checkpoint ВМ
``` 
- последовательность действий:
    - подключиться к win ВМ по RDP
    - подключиться через браузер к адресу сервера управления (ввести дефолт логин, пароль и сменить его)
    - скачать gui консоль из UI
    - подключиться через gui к серверу управления (ввести логин admin, пароль e-gui_console_mgmt-server_password)
    - добавить оба FW в сервер управления (используя SIC password)

## Требования к развертыванию в PROD 
По итогам теста следуйте следующим указаниям для обеспечения безопасности вашей инфраструктуры:
- Обязательно смените пароли, которые были переданы через сервис metadata в файлах: check-init...yaml и cloud-int_win...yaml. Пароли:
    - Пароль администратора windows ВИ
    - Пароль от gui консоли сервера управления
    - Пароль SIC для связи сервера управления и FW
- Сохраните ssh ключ pt_key.pem в надеждное место либо пересоздайте его отдельно от terraform с помощью ваших bastion инструментов
- Удалите публичный адрес у windows ВМ
- Настройте ACL и NAT политики в CheckPoint NGFW
- Учесть особенности облачной сети и не назначать публичные адреса средствами облака на ВМ, у которых в качестве default gateway указан CheckPoint NGFW. Подробности (https://cloud.yandex.ru/docs/vpc/concepts/static-routes#internet-routes)
- Выбрать подходящую лицензию и образ: Для FW Либо PAYG из marketplace либо BYOL , для сервера управления BYOL со своей лицензией
