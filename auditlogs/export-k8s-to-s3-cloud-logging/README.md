# Export of Kubernetes audit logs to Object Storage

This Terraform example deploys a Cloud Function with a Trigger and scraps the Kubernetes cluster audit logs from Cloud Logging group and stores the logs in the Object Storage bucket. 

Cloud Logging group can be created with Yandex Data Streams support, so your audit logs can be forwarded to Yandex Data Stream in parallel.
See [Creating a log group using CLI](https://cloud.yandex.com/en/docs/logging/operations/create-group) instruction for more information.

![image](https://user-images.githubusercontent.com/85429798/186873514-06d204c4-06e8-4239-93be-39817a197f4b.png)

Prerequisites:
- ✅ Cluster of Managed K8s
- ✅ Cloud Logging logging group
- ✅ Terraform

##
1) If you apply this module from Russian Federation – create the `~/.terraformrc` file and specify Yandex Cloud network mirror:
```
cat ~/.terraformrc
provider_installation {
  network_mirror {
    url = "https://terraform-network-mirror.storage.yandexcloud.net/"
  }
}
```
2) Fill out the fields in the `provider.tf` file: specify the token for authentication, or use service account key file.
3) Create a `private.auto.tfvars` file and fill the required variables. (see example of `private.auto.tfvars` file below)
4) Run:

```
terraform init
terraform apply
```

Example of `private.auto.tfvars` file:

```
cloud_id  = "b1g3xxxxxxxxxxxxxxxx"
folder_id = "b1g7xxxxxxxxxxxxxxxx"
cluster_id = "catsxxxxxxxxxxxxxxxx"
logging_group_id = "e23oxxxxxxxxxxxxxxxx"
storage_bucket_name = "audit-log-bucket-xxxxxx"
```
