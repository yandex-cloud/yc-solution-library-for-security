## Export of kubernetes audit logs to s3/object storage

<вставить картинку>


Prerequisites:
- ✅ Cluster of Managed K8s.
- ✅ Terraform
- ✅ Ask cloud support for an alpha flag "LOGS_ALPHA"

##
1) If you doing this from Russia just create the file and fill it out like this to use yandex network mirror:
```
cat ~/.terraformrc
provider_installation {
  network_mirror {
    url = "https://terraform-network-mirror.storage.yandexcloud.net/"
  }
}
```
2) Fill out the fields in the provider.tf file.
3) Fill out the fields in the terraform.tfvars.example file. (example below)
4) Run:

```
terraform init
terraform apply
```


Example of terraform.tfvars.example file:

```
folder_id                      = "b1gvnphpkgt8oechmpo02"
cloud_id                       = "b1g3o4minpkuh10pd2rj2"
cluster_name                   = "k8s-for-export"
log_bucket_name                = "k8s-audit-logs-example"

```