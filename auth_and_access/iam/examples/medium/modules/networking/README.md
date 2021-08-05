# Virtual Privite Cloud (VPC) Terraform module for Yandex.Cloud
## Features

* Create Network and subnets in your folder.
* Easy to use in other resources via outputs.
  
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
| folder\_id | Folder-ID where the resources will be created | `string` | `null` | no |
| labels | A set of key/value label pairs to assign. | `map(string)` | `null` | no |
| network\_description | An optional description of this resource. Provide this property when you create the resource. | `string` | `"terraform-created"` | no |
| network\_name | Name to be used on all the resources as identifier | `string` | n/a | yes |
| subnets | Describe your subnets preferences | <pre>list(object({<br>    zone           = string<br>    v4_cidr_blocks = string<br>  }))</pre> | <pre>[<br>  {<br>    "v4_cidr_blocks": "10.110.0.0/16",<br>    "zone": "ru-central1-a"<br>  },<br>  {<br>    "v4_cidr_blocks": "10.120.0.0/16",<br>    "zone": "ru-central1-b"<br>  },<br>  {<br>    "v4_cidr_blocks": "10.130.0.0/16",<br>    "zone": "ru-central1-c"<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of created network for internal communications |
| subnets | List of maps of subnets used in vpc network: key = v4\_cidr\_block |
| v4\_cidr\_blocks | List of v4\_cidr\_blocks used in vpc network |
| zones | List of zones used in vpc network |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->