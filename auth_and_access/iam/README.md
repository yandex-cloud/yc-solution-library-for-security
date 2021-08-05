# Identity and Access Management (IAM) Terraform module for Yandex.Cloud

## Подробный разбор модуля с примерами по ссылке на вебинар:

[![image](https://user-images.githubusercontent.com/85429798/128347194-3efd9267-6778-4f15-93b9-39813650fe10.png)](https://www.youtube.com/watch?v=7VwSfPZ6eRM&t=3s)

## Примеры использования в папке /examples

## Features

* Create Service accounts and assign them roles in your folder.
* Assign roles to IAM users in cloud and/or folder.
* You can control **authoritatively** all permissions for cloud and/or folder in **one** terraform manifest if needed. See Authoritative flags.
* Replaces IAM groups (aka JOB TITLE) while they are in development.

Use `cloud_user_role_mapping` variable to add permissions to existing IAM users (Yandex.Passport and Federated users) for cloud level.

Use `folder_user_role_mapping` variable to add permissions to existing IAM users (Yandex.Passport and Federated users) for folder level.

Use `sa_role_mapping` variable to create service accounts with permissions for folder level.


### Configure Terraform for Yandex.Cloud 

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud
  
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
``` 

## Troubleshooting

Remember that service accounts in cloud **must** have unique names

You can use following `yc cli` commands for diagnostic:
```
yc resource-manager folder list-operations --id XXXXXXXXXXXXXX

yc resource-manager folder list-access-bindings --id XXXXXXXXXXXXXX
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| yandex | ~> 0.5 |

## Providers

| Name | Version |
|------|---------|
| yandex | ~> 0.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_binding\_authoritative | "Authoritative. Sets the IAM policy for the CLOUD and replaces any **existing** policy already attached. <br>  If Authoritative = true : take roles from all objects in  variable "cloud\_user\_role\_mapping" and make **unique** role as a new key of map with members" | `bool` | `false` | no |
| cloud\_id | Cloud-ID where where need to add permissions. Mandatory variable for CLOUD, if omited default CLOUD\_ID will be used | `string` | `null` | no |
| cloud\_user\_role\_mapping | Group of IAM User-IDs and it's permissions in CLOUD, where name = JOB Tille<br>### Example<br>#cloud\_user\_role\_mapping = [<br>  {<br>    name  = "devops"<br>    users = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]<br>    roles = ["editor", ]<br>  },<br>  {<br>    name  = "developers"<br>    users = ["userAccount:idxxxxxx3"]<br>    roles = ["viewer","k8s.editor",]<br>  },<br> ] | `any` | `[]` | no |
| folder\_binding\_authoritative | Authoritative. Sets the IAM policy for the FOLDER and replaces any **existing** policy already attached. | `bool` | `false` | no |
| folder\_id | Folder-ID where need to add permissions. Mandatory variable for FOLDER, if omited default FOLDER\_ID will be used | `string` | `null` | no |
| folder\_user\_role\_mapping | Group of IAM User-IDs and it's permissions in FOLDER, where name = JOB Tille<br>### Example<br>#folder\_user\_role\_mapping = [<br>  {<br>    name  = "devops"<br>    users = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]<br>    roles = ["iam.serviceAccounts.user", "k8s.editor", "k8s.cluster-api.cluster-admin", "container-registry.admin"]<br>  },<br>  {<br>    name  = "developers"<br>    users = ["userAccount:idxxxxxx3"]<br>    roles = ["k8s.viewer",]<br>  },<br>] | `any` | `[]` | no |
| sa\_role\_mapping | List of SA and it's permissions<br>### Example<br>sa\_role\_mapping = [<br>  {<br>    name  = "sa-cluster"<br>    roles = ["editor",]<br>  },<br>    {<br>    name  = "sa-nodes"<br>    roles = ["container-registry.images.puller",]<br>  },<br>] | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ids | List IDs of created service accounts |
| names | List Names of created service accounts |
| sa | Map with service accounts info , key = service account name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
