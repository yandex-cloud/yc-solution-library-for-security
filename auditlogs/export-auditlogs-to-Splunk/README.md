# Collecting, monitoring, and analyzing audit logs in an external SIEM Splunk

![Dashboard](https://user-images.githubusercontent.com/85429798/130447006-c5a604b3-d1ed-4f47-b132-5e83f02494c8.png)

![Dashboard](https://user-images.githubusercontent.com/85429798/130446967-926e892c-0dcb-4a97-93bc-92fe67b078dd.png)


## Solution description
The solution lets you collect, monitor, and analyze audit logs in Yandex.Cloud from the following sources:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)
- [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/) **(to be announced)** 

## Use cases and searches
The Yandex.Cloud security team has collected the most relevant use cases in the [folder](../_use_cases_and_searches) of the auditlogs repository.

## Solution features implemented via Terraform
- [x] Deploy a COI Instance with a container based on the s3-splunk-importer `cr.yandex/crpjfmfou6gflobbfvfv/s3-splunk-importer:1.0` image.
- [x] Provide continuous delivery of JSON files with audit logs from Yandex Object Storage to Splunk.

## Solution diagram
![Diagram](https://user-images.githubusercontent.com/85429798/130447027-efdd1ee7-0c1b-46fb-b0f2-36577bb5e6a4.png)


## Deployment using Terraform

## Description 

#### Yandex Cloud prerequisites
- :white_check_mark: Object Storage Bucket for Audit Trails.
- :white_check_mark: Audit Trails is enabled in the UI.
- :white_check_mark: VPC network.
- :white_check_mark: COI Instance has access to the internet to download the container image, for example, from the source NAT to the subnet.
- :white_check_mark: ServiceAccount with the *storage.editor* role for actions in Object Storage.

##### See the example of the prerequisite configuration in /example/main.tf

#### Splunk prerequisites
 - :white_check_mark: Configured [HTTP Event Collector](https://docs.splunk.com/Documentation/SplunkCloud/8.2.2105/Data/UsetheHTTPEventCollector#Configure_HTTP_Event_Collector_on_Splunk_Enterprise).
- :white_check_mark: Token for sending events to HEC.

Terraform module /modules/yc-splunk-trail:

- Creates static keys for the SA to work with JSON objects in a bucket and encrypt/decrypt secrets.
- Creates a COI VM with a Docker Container specification using a script.
- Creates an SSH key pair and saves the private part to the disk and the public part to the VM.
- Creates a KMS key.
- Assigns the *kms.keys.encrypterDecrypter* rights to the key for SA to encrypt secrets.
- Encrypts secrets and passes them to Docker Container.


#### Example of calling a module:
```Python
module "yc-splunk-trail" {
    source = "../modules/yc-splunk-trail/" #path to module yc-elastic-trail
    
    folder_id = var.folder_id
    splunk_token = var.splunk_token // Run the command export TF_VAR_splunk_token=<SPLUNK TOKEN> (replace <SPLUNK TOKEN> with your value)
    splunk_server = "https://1.2.3.4" // format: https://<your hostname or address>
    bucket_name = yandex_storage_bucket.trail-bucket.bucket // Specify the name of the bucket with audit trails if the call is not from example
    bucket_folder = "folder" // Specified when creating Trails
    sa_id = yandex_iam_service_account.sa-bucket-editor.id // Specify an SA with bucket_editor rights if the call is not from example
    coi_subnet_id = yandex_vpc_subnet.splunk-subnet[0].id // Specify the subnet_id if the call is not from example
}

```
