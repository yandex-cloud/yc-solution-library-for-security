# Collecting, monitoring and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)

![Dashboard](https://user-images.githubusercontent.com/85429798/127686785-27658104-6258-4de8-929f-9cf87624fa27.png)

# Version

**Version-2.1**
- Changelog:
    - Added new use cases from [Use cases and important security events in audit logs](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/_use_cases_and_searches#use-cases-%D0%B8-%D0%B2%D0%B0%D0%B6%D0%BD%D1%8B%D0%B5-%D1%81%D0%BE%D0%B1%D1%8B%D1%82%D0%B8%D1%8F-%D0%B1%D0%B5%D0%B7%D0%BE%D0%BF%D0%B0%D1%81%D0%BD%D0%BE%D1%81%D1%82%D0%B8-%D0%B2-%D0%B0%D1%83%D0%B4%D0%B8%D1%82-%D0%BB%D0%BE%D0%B3%D0%B0%D1%85)"
- Docker images:
    - `cr.yandex/sol/s3-elk-importer:2.1`
    - `cr.yandex/sol/elk-updater:1.0.4`

**Version-2.0**
- Changelog:
    - Добавлен фильтр по Folder name
- Docker images:
    - `cr.yandex/sol/s3-elk-importer:1.0.6`

# Table of contents
- [Solution description](#solution-description)
- [Solution features](#solution-features)
- [Solution diagram](#solution-diagram)
- [Security Content](#security-content)
- [License restrictions](#license-restrictions)
- [Content update process](#content-update-process)
- [Deployment using Terraform](#deployment-using-Terraform)
- [Deployment of a solution to supply K8s logs] (#deployment-of-a-solution-to-supply-k8s-logs)
- [Recommendations for setting up retention, rollover, and snapshots](#recommendations-for-setting-retention-rollover-and-snapshots)

## Solution description
The solution lets you collect, monitor, and analyze audit logs in Yandex Managed Service for Elasticsearch (ELK) from the following sources:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)
- [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/): audit logs, Falco alerts, and Policy Engine (OPA Gatekeeper) ([setup description](../export-auditlogs-to-ELK_k8s))

> The solution is constantly updated and maintained by the Yandex.Cloud Security team.


## Solution features
- ☑️ Deploy a Managed ELK cluster in the Yandex.Cloud infrastructure via Terraform. In the default configuration, see Deployment using Terraform. Calculate the relevant configuration for your infrastructure together with your cloud architect.
- ☑️ Deploy a COI Instance with container based on the s3-elk-importer image (`cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest`).
- ☑️ Upload Security Content to ELK: Dashboards, Detection Rules with alerts, etc.
- ☑️ Enable continuous delivery of JSON files with audit logs from Yandex Object Storage to ELK.
- ☑️ Create indexes in two replicas, configure the basic rollover policy (create new indexes every thirty days or after reaching 50 GB). For further provisioning for high data availability and setting up data snapshots in S3, see [recommendations](./CONFIGURE-HA.md). 

## Solution diagram
![image](https://user-images.githubusercontent.com/85429798/137448275-ce665493-8dc4-498f-9dbe-ae7dfcffbec9.png)


[Diagram of the solution to supply K8s logs](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_k8s)


## Security Content
**Security Content** are ELK objects automatically loaded by the solution. All the content leverages the long-term expertise of the Yandex.Cloud Security team and our cloud customers.

The solution contains the following Security Content:
- Dashboard that reflects all use cases and useful statistics.
- A set of Saved Queries for easy search of Security events.
- A set of Detection Rules: the correlation rules for which alerts are configured (the client should specify the alert destination).

All relevant event fields have been converted to the [Elastic Common Schema (ECS)] (https://www.elastic.co/guide/en/ecs/current/index.html) format, the full mapping table is in the [file with object description](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf).

A detailed description is in the [ECS-mapping.docx](./papers/ECS-mapping_new.pdf) file


## License restrictions

![image](https://user-images.githubusercontent.com/85429798/137449824-329e7eea-58d0-4aef-81e9-c1f53da6b39c.png)
![image](https://user-images.githubusercontent.com/85429798/137449722-6aae24e6-f567-4a4f-b52e-3c9f63893ac9.png)
[Subscription options on ELK site](https://www.elastic.co/subscriptions)

## Content update process
We recommend subscribing to this repository to receive update notifications.

To get the latest content version, do the following:
- Keep the sync container up-to-date.
- Keep the Security content imported to Elasticsearch in the updated state.

For content updates, make sure that you are running the latest available image version: `cr.yandex/crpjfmfou6gflobbfvfv/s3-elk-importer:latest`.

You can update the container as follows:
- You can re-create the deployed COI Instance with the container via Terraform (delete the COI Instance and run: `terraform apply`).
- You can stop and delete the `audit-trail-worker-*` container, delete the `s3-elk-importer` image, and restart COI Instance. After the launch, a new image will be downloaded and a new container will be created.

You can update the Security content in Kibana (dashboards, detection rules, searches) by launching the elk-updater container:

```
docker run -it --rm -e ELASTIC_AUTH_USER='admin' -e ELASTIC_AUTH_PW='password' -e KIBANA_SERVER='https://xxx.rw.mdb.yandexcloud.net' --name elk-updater cr.yandex/crpjfmfou6gflobbfvfv/elk-updater:latest
```

## Deployment using Terraform

#### Description 

#### Prerequisites:
- :white_check_mark: Object Storage Bucket for Audit Trails.
- :white_check_mark: [Audit Trails service enabled](https://cloud.yandex.ru/docs/audit-trails/quickstart) in the UI.
- :white_check_mark: VPC network.
- :white_check_mark: Subnets in three availability zones.
- :white_check_mark: COI Instance has access to the internet to download the container image.
- :white_check_mark: ServiceAccount with the *storage.editor* role for actions in Object Storage.

See the example of configuring prerequisites and calling modules in [/example/main.tf](./terraform/example) 
## 
The solution consists of two Terraform modules [/terraform/modules/](./terraform/modules):
- yc-managed-elk creates a cluster [Yandex Managed Service for Elasticsearch](https://cloud.yandex.ru/services/managed-elasticsearch):
- With three nodes (one for each availability zone).
- With a Gold license.
- Characteristics: s2-medium (8 vCPU, 32GB RAM), HDD: 1TB.
- A password to the ELK admin account.

- yc-elastic-trail:
- Creates static keys for the SA (for working with JSON objects in a bucket and encrypting/decrypting secrets).
- Creates a COI VM with a Docker Container specification using a script.
- Creates an SSH key pair and saves the private part to the disk and the public part to the VM.
- Creates a KMS key.
- Assigns the kms.keys.encrypterDecrypter rights to the key for SA to encrypt secrets.
- Encrypts secrets and passes them to Docker Container.


#### Example of calling modules:
```Python
module "yc-managed-elk" {
    source     = "../modules/yc-managed-elk" # path to module yc-managed-elk    
    folder_id  = var.folder_id
    subnet_ids = yandex_vpc_subnet.elk-subnet[*].id # Subnets in three availability zones for ELK deployment
    network_id = yandex_vpc_network.vpc-elk.id # The ID of the network where ELK will be deployed
    elk_edition = "gold"
    elk_datanode_preset = "s2.medium"
    elk_datanode_disk_size = 1000
    elk_public_ip = false # true if you need a public access to Elasticsearch
}

module "yc-elastic-trail" {
    source          = "../modules/yc-elastic-trail/" # path to module yc-elastic-trail
    folder_id       = var.folder_id
    elk_credentials = module.yc-managed-elk.elk-pass
    elk_address     = module.yc-managed-elk.elk_fqdn
    bucket_name     = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder = "" # Specify the name of the prefix where trails writes logs to the bucket, for example prefix-trails (if it's root, then leave empty at default)
    sa_id           = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id   = yandex_vpc_subnet.elk-subnet[0].id
}

output "elk-pass" {
  value     = module.yc-managed-elk.elk-pass
  sensitive = true
} // View the ELK password: terraform output elk-pass
output "elk_fqdn" {
  value = module.yc-managed-elk.elk_fqdn
} // Outputs the ELK URL that can be accessed, for example, through the browser 

output "elk-user" {
  value = "admin"
}
    
```

## Deployment of a solution to supply K8s logs
[Deployment of the K8s log delivery solution](../export-auditlogs-to-ELK_k8s)

## Recommendations for setting up retention, rollover, and snapshots

[Recommendations for setting up retention, rollover, and snapshots](./CONFIGURE-HA.md)
