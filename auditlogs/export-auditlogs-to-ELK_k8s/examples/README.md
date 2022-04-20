## Terraform test script 

Prerequisites:
- ✅ Cluster of Managed K8s.
- ✅ Managed ELK.
- ✅ A service account that can write to the bucket and has the *ymq.admin* role.

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
4) Delete <.example> from the end of the file - terraform.tfvars
5) Run:

```
terraform init
terraform apply
```


Example of terraform.tfvars.example file:

```
folder_id                      = "example"
cloud_id                       = "example"
cluster_name                   = "example-cluster"
elastic_server                 = "https://example-es.rw.mdb.yandexcloud.net"
elastic_pw                     = "str0ng_password"
elastic_user                   = "example_user"
service_account_id             = "k8s-audit-logs-example"
log_bucket_name                = "k8s-audit-logs-example" #name of cluster that will be create
worker_docker_image            = "cr.yandex/sol/k8s-events-siem-worker:2.0.0"
create_namespace               = true
auditlog_enabled               = true
auditlogs_prefix               = "AUDIT/"
auditlog_worker_chart_name     = "auditlog-worker-example"
auditlog_worker_namespace      = "infra-auditlog-example"
auditlog_worker_replicas_count = 1
falco_enabled                  = true
falco_prefix                   = "FALCO/"
falco_worker_chart_name        = "falco-worker-example"
falco_worker_namespace         = "infra-auditlog-example"
falco_worker_replicas_count    = 3
falco_helm_namespace           = "falco-example"
falco_version                  = "1.17.0"
falcosidekick_version          = "0.4.4"
kyverno_enabled                = true
kyverno_prefix                 = "KYVERNO/"
kyverno_worker_chart_name      = "kyverno-worker-example"
kyverno_worker_namespace       = "infra-auditlog-example"
kyverno_worker_replicas_count  = 1
kyverno_helm_namespace         = "kyverno-example"
kyverno_version                = "2.1.10"
kyverno_policies_version       = "2.1.10"
policy_reporter_version        = "2.2.3"
fakeeventgenerator_enabled     = false

```