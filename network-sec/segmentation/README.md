# Terraform and Security Groups Example 2
Mock dev/stage/prod environment with sample security groups to provide isolation

## Предварительная настройка
Заполняем файл terraform.tfvars_example и переименовываем его в terraform.tfvars
В файл вносим свои значения cloud_id; folder_id (для всех 4 каталогов); token;
В файле variables.tf заменяем значение переменной `bastion_whitelist_ip` на собственный список публичных адресов с которых разрешено подключаться к схеме (через запятую, каждый адрес в двойных кавычках например `default = ["1.1.1.1/32", "2.2.2.2/32"]`)
- запускаем `terraform init`
- запускаем`terraform apply`
-
