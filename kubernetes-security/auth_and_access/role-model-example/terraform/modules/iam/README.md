# Identity and Access Management (IAM) Terraform module for Yandex.Cloud
## Features

* Create Service accounts and assign them roles in your folder.
* Assign roles to IAM users in cloud and/or folder.
* You can control **authoritatively** all permissions for cloud and/or folder in **one** terraform manifest if needed. See Authoritative flags.
* Replaces IAM groups (aka JOB TITLE) while they are in development.

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

## Modules

No Modules.

## Resources

| Name |
|------|
| [yandex_client_config](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) |
| [yandex_iam_policy](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_policy) |
| [yandex_iam_service_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) |
| [yandex_resourcemanager_cloud_iam_binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_binding) |
| [yandex_resourcemanager_cloud_iam_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member) |
| [yandex_resourcemanager_folder_iam_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) |
| [yandex_resourcemanager_folder_iam_policy](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_policy) |

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