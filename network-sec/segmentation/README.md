# Terraform and Security Groups Example 2
Mock dev/stage/prod environment with sample security groups to provide isolation

## Подбробный разбор на видео
[![image](https://user-images.githubusercontent.com/85429798/128601756-b790bab4-0be5-4843-bc79-b15187023955.png)](https://www.youtube.com/watch?v=MeJ8fTS2iGU&t=854s)


## Предварительная настройка
Заполняем файл terraform.tfvars_example и переименовываем его в terraform.tfvars
В файл вносим свои значения cloud_id; folder_id (для всех 4 каталогов); token;
В файле variables.tf заменяем значение переменной `bastion_whitelist_ip` на собственный список публичных адресов с которых разрешено подключаться к схеме (через запятую, каждый адрес в двойных кавычках например `default = ["1.1.1.1/32", "2.2.2.2/32"]`)
- запускаем `terraform init`
- запускаем`terraform apply`
-
