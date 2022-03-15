## Deployment using Terraform

#### Description 

The solution consists of two [Terraform modules](/terraform/modules/):
1) yc-managed-elk creates a cluster [Yandex Managed Service for Elasticsearch](https://cloud.yandex.ru/services/managed-elasticsearch). 
- With three nodes (one for each availability zone).
- With a Gold license.
- Characteristics: s2-medium (8 vCPU, 32GB RAM).
- HDD: 1TB.
- Assigns a password to the ELK admin account.

2) yc-elastic-trail:
- Creates static keys for the SA (for working with JSON objects in a bucket and encrypting/decrypting secrets).
- Creates a COI VM with a Docker Container specification using a script.
- Creates an SSH key pair and saves the private part to the disk and the public part to the VM.
- Creates a KMS key.
- Assigns the *kms.keys.encrypterDecrypter* rights to the key for SA to encrypt secrets.
- Encrypts secrets and passes them to Docker Container.

### Prerequisites:
- :white_check_mark: Object Storage Bucket for Audit Trails.
- :white_check_mark: Enabled Audit Trails service in the UI.
- :white_check_mark: VPC network.
- :white_check_mark: Subnets in three availability zones.
- :white_check_mark: A service account with the *storage.editor* role for actions on Object Storage.

**See the example of the prerequisite configuration in /example/main.tf**


### Example of calling modules:
```Python
module "yc-managed-elk" {
    source     = "../modules/yc-managed-elk" # path to module yc-managed-elk    
    folder_id  = var.folder_id
    subnet_ids = yandex_vpc_subnet.elk-subnet[*].id # Subnets in three availability zones for ELK deployment
    network_id = yandex_vpc_network.vpc-elk.id # The ID of the network where ELK will be deployed
    elk_edition = "gold"
    elk_datanode_preset = "s2.medium"
    elk_datanode_disk_size = 1000
    elk_public_ip = false # true if you need public access to Elasticsearch
}

module "yc-elastic-trail" {
    source          = "../modules/yc-elastic-trail/" # path to module yc-elastic-trail
    folder_id       = var.folder_id
    elk_credentials = module.yc-managed-elk.elk-pass
    elk_address     = module.yc-managed-elk.elk_fqdn
    bucket_name     = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder = "" # Specify the name of the prefix where trails writes logs to the bucket, for example *prefix-trails* (if it's root, then leave empty at default)
    sa_id           = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id   = yandex_vpc_subnet.elk-subnet[0].id
}

output "elk-pass" {
  value     = module.yc-managed-elk.elk-pass
  sensitive = true
} // View the ELK password: terraform output elk-pass
output "elk_fqdn" {
  value = module.yc-managed-elk.elk_fqdn
} // Outputs the ELK URL that can be accessed in the browser, for example 

output "elk-user" {
  value = "admin"
}
    
```
