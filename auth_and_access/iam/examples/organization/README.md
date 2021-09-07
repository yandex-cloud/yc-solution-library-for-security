# Assign roles for Organization and Cloud to IAM users

Remember to change your  **Organization-ID**, **CLOUD-ID**, **USER-ID** in `main.tf`.

## Configure Terraform for Yandex.Cloud 

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud
  
```
export YC_TOKEN=$(yc iam create-token)

``` 
## Quick Start

To run this example you need to execute:
```
terraform init
terraform plan
terraform apply
```