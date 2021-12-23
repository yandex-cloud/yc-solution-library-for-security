# Yandex.SCALE 2021 Assigning roles for to IAM users

## Configure Terraform for Yandex.Cloud 

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud
  
```
export YC_TOKEN=$(yc iam create-token)

``` 
## Quick Start
Rename `terraform.tfvars.example` to `terraform.tfvars` and add your values

To execute run:
```
terraform init
terraform plan
terraform apply
```