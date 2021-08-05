# Create service accounts and assign roles to IAM users

Remember to change your **folder-ID** in variables.

## Configure Terraform for Yandex.Cloud 

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud
  
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
``` 
## Quick Start

To run this example you need to execute:
```
terraform init
terraform plan
terraform apply
```