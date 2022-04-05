# Installing a Damn Vulnerable Web Application (DVWA) in Yandex.Cloud using Terraform for managed WAF testing

Link to a video review on YouTube: https://www.youtube.com/watch?v=r7Dxv_as24E

Terraform playbook will create:
- New VPC network and VPC subnet
- External VPC address
- Security group to access the application
- VM based on [Yandex Container Solution](https://cloud.yandex.ru/docs/cos/) running a Docker container with a [Damn Vulnerable Web Application (DVWA)](https://dvwa.co.uk/)

## Prerequisites:
- Bash.
- [Terraform](https://www.terraform.io/downloads.html).
- [YC CLI](https://cloud.yandex.ru/docs/cli/operations/install-cli), a user with the admin or editor role at the folder level.

## Installation
- Copy repository files using Git:
```
git clone https://github.com/mirtov-alexey/dvwa_and_managed_waf.git 
```
- Fill out the variables in the variables.tf file: in the `token` field, enter either the user's OAuth token or a [path to the service account's key file](https://cloud.yandex.ru/docs/cli/operations/authentication/service-account).
- In the provider.tf file, specify `token = var.token` (for user authentication) or `service_account_key_file = var.token` (for authenticating on behalf of the service account).
- Go to the file folder and run terraform init:
```
cd ./dvwa_and_managed_waf/
terraform init
```
- Next, run terraform apply:
```
terraform apply
```
## Installation results
- As a result of the installation, an external IP address will be displayed in the command line:
![image](https://user-images.githubusercontent.com/85429798/120917860-2e6c5380-c6ba-11eb-87a6-336d6f4f8593.png)


- Next, when you open the address in the browser, you should see the following:
![image](https://user-images.githubusercontent.com/85429798/120917903-5d82c500-c6ba-11eb-802d-9bc4b622ec96.png)

- Enter login: 'admin`, password: 'password`.
- At the very bottom of the page, click Create/Reset database.
- Then click Login at the bottom.
- On the DVWA Security tab, change the level to Low.
- Go to the SQL Injection tab and in the User ID field, enter the following: 
```
`%' and 1=0 union select null, concat(user,':',password) from users #`
```

![image](https://user-images.githubusercontent.com/85429798/120918060-252fb680-c6bb-11eb-8398-32c98e2f70ca.png)

