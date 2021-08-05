# Terraform and Security Groups Example 1
Mock web-application environment with security groups to provide secure remote-access and isolation

## Предварительная настройка
Заполняем файл terraform.tfvars_example и переименовываем его в terraform.tfvars
В файл вносим свои значения cloud_id; folder_id; token;
В файле variables.tf заменяем значение переменной `remote_whitelist_ip` на собственный список публичных адресов с которых разрешено подключаться к схеме (через запятую, каждый адрес в двойных кавычках например `default = ["1.1.1.1/32", "2.2.2.2/32"]`)
В том-же файле поменяйте значение переменной ipsec_password на желаемый пароль для тестового ipsec соединения
- запускаем `terraform init`
- запускаем`terraform apply`
-
