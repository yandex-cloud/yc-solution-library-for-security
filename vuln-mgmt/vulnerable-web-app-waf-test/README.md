# Установка уязвимого веб приложения (dvwa) в Яндекс Облаке (с помощью terraform) для тестирования managed WAF

Ссылка на видео-обзор на youtube - https://www.youtube.com/watch?v=r7Dxv_as24E

Terraform playbook создаст:
- новую vpc network и vpc subnet;
- внешний vpc address;
- security group для доступа к приложению;
- VM на базе [Yandex Container Solution](https://cloud.yandex.ru/docs/cos/) c запущенным docker контейнером с [Damn Vulnerable Web Application (DVWA)](https://dvwa.co.uk/)

## Пререквизиты
- bash
- [terraform](https://www.terraform.io/downloads.html)
- [cli yandex cloud](https://cloud.yandex.ru/docs/cli/operations/install-cli), пользователь (роль: admin или editor на уровне folder)
## Установка
- скопировать файлы репозитория с помощью git:
```
git clone https://github.com/mirtov-alexey/dvwa_and_managed_waf.git 
```
- заполнить переменные в файле - "variables.tf" (в поле token необходимо ввести либо oauth token пользователя либо [путь к файлу ключа service account](https://cloud.yandex.ru/docs/cli/operations/authentication/service-account))
- в файле "provider.tf" указать token = var.token (для аутентификациии пользователя) или service_account_key_file = var.token (для аутентификации от service account)
- перейти в папку с файлами и запустить terraform init 
```
cd ./dvwa_and_managed_waf/
```
```
terraform init
```
- далее запустить terraform apply
```
terraform apply
```
## Результаты установки
- По результату установки в командной строке будет показан внешний ip адрес:
![image](https://user-images.githubusercontent.com/85429798/120917860-2e6c5380-c6ba-11eb-87a6-336d6f4f8593.png)


- Далее при переходе по адресу через браузер вы должны видеть следующее:
![image](https://user-images.githubusercontent.com/85429798/120917903-5d82c500-c6ba-11eb-802d-9bc4b622ec96.png)

- введите логин: admin, пароль: password
- в самом низу страницы будет кнопка "create /reset database" - нажмите ее
- далее внизу нажмите login
- во вкладке "DVWA Security" поменяйте уровень на "low"
- перейдите во вкладку "SQL Injection" и введите в поле User ID следующее: `%' and 1=0 union select null, concat(user,':',password) from users #`

![image](https://user-images.githubusercontent.com/85429798/120918060-252fb680-c6bb-11eb-8398-32c98e2f70ca.png)


