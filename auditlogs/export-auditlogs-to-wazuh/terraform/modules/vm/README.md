## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | 0.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.77.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_compute_instance.instance](https://registry.terraform.io/providers/yandex-cloud/yandex/0.77.0/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az"></a> [az](#input\_az) | The availability zone where the virtual machine will be created. If it is not provided, the default provider folder is used. | `string` | `"ru-central1-a"` | no |
| <a name="input_boot_disk"></a> [boot\_disk](#input\_boot\_disk) | Disk type | `string` | `"network-hdd"` | no |
| <a name="input_core_fraction"></a> [core\_fraction](#input\_core\_fraction) | Specifies baseline performance for a core as a percent | `number` | `20` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | CPU cores for the instance | `string` | `2` | no |
| <a name="input_count_format"></a> [count\_format](#input\_count\_format) | Default count format | `string` | `"%01d"` | no |
| <a name="input_count_offset"></a> [count\_offset](#input\_count\_offset) | Default count offset | `number` | `0` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the disk in GB. | `string` | `100` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | A disk image to initialize this disk from | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Vm(s) count | `string` | `1` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Resource name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of virtual machine to create. The default is 'standard-v1' | `string` | `"standard-v1"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels for resources | `map(string)` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory size in GB | `string` | `2` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | ID of the service account authorized for this instance. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | YID of the subnet to attach this interface to. The subnet must exist in the same zone where this instance will be created. | `string` | n/a | yes |
| <a name="input_use_nat"></a> [use\_nat](#input\_use\_nat) | Provide a public address, for instance, to access the internet over NAT. | `bool` | `false` | no |
| <a name="input_vm_metadata"></a> [vm\_metadata](#input\_vm\_metadata) | Metadata key/value pairs to make available from within the instance. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | n/a |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | Virtual Machine private ip address |
| <a name="output_vm_public_ip"></a> [vm\_public\_ip](#output\_vm\_public\_ip) | Virtual Machine public ip address |
