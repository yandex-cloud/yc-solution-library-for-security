# Multi-environment infrastructure with centralized RBAC management

Use `iam_mgmt` folder to set roles.

Use `data.data.terraform_remote_state` to use newly created service accounts in dev/prod folders.

Remember to change your **folder-IDs** in all environment folders.

## Configure Terraform for Yandex.Cloud 

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud
  
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
``` 
## Quick Start

To run this example you need to execute from **all** folders:
```
terraform init
terraform plan
terraform apply
```