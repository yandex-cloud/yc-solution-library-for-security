#
Подготовка:

-установить yc client (ссылка на инструкцию по установке и настройке https://cloud.yandex.ru/docs/cli/quickstart)
-настроить авторизацию в YC для Terraform:

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

-установить terraform https://www.terraform.io/downloads.html
-скопировать файлы репозитория с помощью git:
git clone --значек download


Развертывание:
-перейти в папку со скаченными файлами
-terraform init
-terraform apply 
