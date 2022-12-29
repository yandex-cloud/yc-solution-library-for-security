## Export of kubernetes audit logs to Yandex Data Streams/Kinesis Data Streams

![image](https://user-images.githubusercontent.com/85429798/186873675-1769f228-d965-406f-b917-165959755333.png)


Prerequisites:
- ✅ Cluster of Managed K8s.
- ✅ Terraform
- ✅ Ask cloud support for an alpha flag "LOGS_ALPHA"
- ✅ [Existing Yandex Data Streams](https://cloud.yandex.ru/services/data-streams)
- ✅ To get the **yds_id** parameter, go to the deployed YDS and copy it from the endpoint tab, for example
https://yds.serverless.yandexcloud.net/ru-central1/b1g3o4minpkuh10pd2rj/**etnrmbadnrson5algn3s**/stream-for-k8s-audit . Parameter etnrmbadnrson5algn3s is yds id

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
folder_id                      = "b1gvnphpkgt8oechmpo0"
cloud_id                       = "b1g3o4minpkuh10pd2rj"
cluster_name                   = "k8s-for-export"

yds_stream_name = "stream-for-k8s-audit"
yds_id = "b1g3o4minpkuh10pd2rj" 
yds_ydb_id = "etnrmbadnrson5algn3s"

```
