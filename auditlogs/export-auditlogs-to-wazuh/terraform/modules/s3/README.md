## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | 0.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.77.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [yandex_iam_service_account.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account_static_access_key.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_resourcemanager_cloud_iam_binding.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/resourcemanager_cloud_iam_binding) | resource |
| [yandex_resourcemanager_folder_iam_binding.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/resourcemanager_folder_iam_binding) | resource |
| [yandex_storage_bucket.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/storage_bucket) | resource |
| [yandex_resourcemanager_cloud.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/data-sources/resourcemanager_cloud) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | The ID of the cloud to apply any resources to | `string` | n/a | yes |
| <a name="input_count_format"></a> [count\_format](#input\_count\_format) | Default count format | `string` | `"%01d"` | no |
| <a name="input_count_offset"></a> [count\_offset](#input\_count\_offset) | Default count offset | `number` | `0` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | ID of the folder to attach a policy to. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the network load balancer. Provided by the client when the network load balancer is created. | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | The roles that should be assigned | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_key_id"></a> [aws\_key\_id](#output\_aws\_key\_id) | n/a |
| <a name="output_aws_secret_access_key"></a> [aws\_secret\_access\_key](#output\_aws\_secret\_access\_key) | n/a |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_iam_profile_id"></a> [iam\_profile\_id](#output\_iam\_profile\_id) | n/a |
| <a name="output_iam_profile_name"></a> [iam\_profile\_name](#output\_iam\_profile\_name) | n/a |
