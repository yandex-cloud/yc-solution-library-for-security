# Identity and Access Management (IAM) Terraform module for Yandex.Cloud

## Full review of module usage on youtube:

[![image](https://user-images.githubusercontent.com/85429798/128347194-3efd9267-6778-4f15-93b9-39813650fe10.png)](https://www.youtube.com/watch?v=7VwSfPZ6eRM&t=3s)

## Features

* Create Service accounts and assign them roles in your folder.
* Assign roles to IAM users in organization and/or cloud and/or folder.
* You can control **authoritatively** all permissions for organization, cloud and folder in **one** terraform manifest if needed. See Authoritative flags.
* Replaces IAM groups (aka JOB TITLE) while they are in development.

Use `org_user_role_mapping` variable to add permissions to existing IAM users (Yandex.Passport and Federated users) for organization level.

Use `cloud_user_role_mapping` variable to add permissions to existing IAM users (Yandex.Passport and Federated users) for cloud level.

Use `folder_user_role_mapping` variable to add permissions to existing IAM users (Yandex.Passport and Federated users) for folder level.

To use IAM usernames(YandexID accounts) and Federated accounts as input variables '**iam_users_names**' and '**fed_users_names**' put `usernames_to_ids = true`. You can also use '**users_with_ids**' with IDs and all of them together. See example in variables' descriptions

Use `sa_role_mapping` variable to create service accounts with permissions for folder level.


## Configure Terraform for Yandex.Cloud 

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
To **import** existing service accounts use:

```
terraform import 'module.<module name>.yandex_iam_service_account.sa["<SA-name>"]' <SA id>

or

terraform import 'module.iam.yandex_iam_service_account.sa["sa-robot"]' aje0am0b06tj6v8mXXXX
```
Then add `SA-name` to your variables and try `terraform plan`

Correct resource path can be found with `terraform state list`

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name                                                                      | Version |
| ------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0  |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex)          | ~> 0.68 |

## Providers

| Name                                                       | Version |
| ---------------------------------------------------------- | ------- |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.68.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                            | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [yandex_iam_service_account.sa](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account)                                                                          | resource    |
| [yandex_organizationmanager_organization_iam_binding.org_binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_organization_iam_binding)               | resource    |
| [yandex_organizationmanager_organization_iam_member.org_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/organizationmanager_organization_iam_member)                  | resource    |
| [yandex_resourcemanager_cloud_iam_binding.cloud_binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_binding)                                   | resource    |
| [yandex_resourcemanager_cloud_iam_member.cloud_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_cloud_iam_member)                                      | resource    |
| [yandex_resourcemanager_folder_iam_member.folder_sa_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member)                                | resource    |
| [yandex_resourcemanager_folder_iam_member.folder_user_member](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member)                              | resource    |
| [yandex_resourcemanager_folder_iam_policy.folder_bindings_policy](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_policy)                          | resource    |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config)                                                                               | data source |
| [yandex_iam_policy.bindings](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_policy)                                                                                   | data source |
| [yandex_iam_user.cloud_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_user)                                                                                  | data source |
| [yandex_iam_user.folder_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_user)                                                                                 | data source |
| [yandex_iam_user.org_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_user)                                                                                    | data source |
| [yandex_organizationmanager_saml_federation_user_account.cloud_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/organizationmanager_saml_federation_user_account)  | data source |
| [yandex_organizationmanager_saml_federation_user_account.folder_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/organizationmanager_saml_federation_user_account) | data source |
| [yandex_organizationmanager_saml_federation_user_account.org_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/organizationmanager_saml_federation_user_account)    | data source |

## Inputs

| Name                                                                                                                       | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Type     | Default | Required |
| -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_cloud_binding_authoritative"></a> [cloud\_binding\_authoritative](#input\_cloud\_binding\_authoritative)    | "Authoritative. Sets the IAM policy for the CLOUD and replaces any **existing** policy already attached. <br>  If Authoritative = true : take roles from all objects in  variable "cloud\_user\_role\_mapping" and make **unique** role as a new key of map with members"                                                                                                                                                                                                                                                                                                                                                                     | `bool`   | `false` |    no    |
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id)                                                               | Cloud-ID where where need to add permissions. Mandatory variable for CLOUD, if omited default CLOUD\_ID will be used                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `string` | `null`  |    no    |
| <a name="input_cloud_user_role_mapping"></a> [cloud\_user\_role\_mapping](#input\_cloud\_user\_role\_mapping)              | Group of IAM User-IDs and it's permissions in CLOUD, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both<br>### Example<br>#cloud\_user\_role\_mapping = [<br>  {<br>    job\_title\_name  = "devops"<br>    iam\_users\_names = ["name.surname", ]<br>    fed\_users\_names = ["name.surname@yantoso.ru", ]<br>    roles = ["editor", ]<br>  },<br>  {<br>    job\_title\_name  = "developers"<br>    users\_with\_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]<br>    iam\_users\_names = ["name.surname", ]<br>    roles = ["viewer","k8s.editor",]<br>  },<br> ]                                      | `any`    | `[]`    |    no    |
| <a name="input_federation_id"></a> [federation\_id](#input\_federation\_id)                                                | Federation ID, mandatory for 'fed\_users\_names'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `string` | `null`  |    no    |
| <a name="input_folder_binding_authoritative"></a> [folder\_binding\_authoritative](#input\_folder\_binding\_authoritative) | Authoritative. Sets the IAM policy for the FOLDER and replaces any **existing** policy already attached.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `bool`   | `false` |    no    |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id)                                                            | Folder-ID where need to add permissions. Mandatory variable for FOLDER, if omited default FOLDER\_ID will be used                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `string` | `null`  |    no    |
| <a name="input_folder_user_role_mapping"></a> [folder\_user\_role\_mapping](#input\_folder\_user\_role\_mapping)           | Group of IAM User-IDs and it's permissions in FOLDER, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both<br>### Example<br>#folder\_user\_role\_mapping = [<br>  {<br>    job\_title\_name  = "devops"<br>    iam\_users\_names = ["name.surname", ]<br>    fed\_users\_names = ["name.surname@yantoso.ru", ]<br>    roles = ["iam.serviceAccounts.user", "k8s.editor", "k8s.cluster-api.cluster-admin", "container-registry.admin"]<br>  },<br>  {<br>    job\_title\_name  = "developers"<br>    users\_with\_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]<br>    roles = ["k8s.viewer",]<br>  },<br>] | `any`    | `[]`    |    no    |
| <a name="input_org_binding_authoritative"></a> [org\_binding\_authoritative](#input\_org\_binding\_authoritative)          | "Authoritative. Sets the IAM policy for the ORGANIZATION and replaces any **existing** policy already attached. <br>  If Authoritative = true : take roles from all objects in  variable "org\_user\_role\_mapping" and make **unique** role as a new key of map with members"                                                                                                                                                                                                                                                                                                                                                                | `bool`   | `false` |    no    |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id)                                                                     | ORGANIZATION-ID where where need to add permissions. Mandatory variable for ORGANIZATION, if omited default ORGANIZATION\_ID will be used                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `string` | `null`  |    no    |
| <a name="input_org_user_role_mapping"></a> [org\_user\_role\_mapping](#input\_org\_user\_role\_mapping)                    | Group of IAM User-IDs and it's permissions in ORGANIZATION, where name = JOB Tille(aka IAM Group). Use usernames or user-ids or both<br>### Example<br>#org\_user\_role\_mapping = [<br>  {<br>    job\_title\_name  = "admins"<br>    iam\_users\_names = ["name.surname", ]<br>    fed\_users\_names = ["name.surname@yantoso.ru", ]<br>    roles = ["admin",]<br>  },<br>  {<br>    job\_title\_name  = "network\_admins"<br>    sers\_with\_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]<br>    roles = ["vpc.admin",]<br>  },<br> ]                                                                                       | `any`    | `[]`    |    no    |
| <a name="input_sa_role_mapping"></a> [sa\_role\_mapping](#input\_sa\_role\_mapping)                                        | List of SA and it's permissions<br>### Example<br>sa\_role\_mapping = [<br>  {<br>    name  = "sa-cluster"<br>    roles = ["editor",]<br>  },<br>    {<br>    name  = "sa-nodes"<br>    roles = ["container-registry.images.puller",]<br>  },<br>]                                                                                                                                                                                                                                                                                                                                                                                            | `any`    | `[]`    |    no    |
| <a name="input_usernames_to_ids"></a> [usernames\_to\_ids](#input\_usernames\_to\_ids)                                     | If true Usernames from IAM and Federation will be used as input variables 'iam\_users\_names' and 'fed\_users\_names'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `bool`   | `true`  |    no    |

## Outputs

| Name                                                              | Description                                                 |
| ----------------------------------------------------------------- | ----------------------------------------------------------- |
| <a name="output_sa_ids"></a> [sa\_ids](#output\_sa\_ids)          | List IDs of created service accounts                        |
| <a name="output_sa_names"></a> [sa\_names](#output\_sa\_names)    | List Names of created service accounts                      |
| <a name="output_sa_object"></a> [sa\_object](#output\_sa\_object) | Map with service accounts info , key = service account name |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->