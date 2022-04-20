## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_kustomization"></a> [kustomization](#requirement\_kustomization) | >= 0.5.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.auditlog_worker](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.falco](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.falco_worker](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.falcosidekick](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kyverno](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kyverno-policies](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kyverno_worker](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.policy_reporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.project_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_timer](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [yandex_function.k8s_log_exporter](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function) | resource |
| [yandex_function.s3_ymq_for_auditlog](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function) | resource |
| [yandex_function.s3_ymq_for_falco](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function) | resource |
| [yandex_function.s3_ymq_for_kyverno](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function) | resource |
| [yandex_function_trigger.logs-trigger](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function_trigger) | resource |
| [yandex_function_trigger.s3_ymq_auditlog_trigger](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function_trigger) | resource |
| [yandex_function_trigger.s3_ymq_falco_trigger](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function_trigger) | resource |
| [yandex_function_trigger.s3_ymq_kyverno_trigger](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/function_trigger) | resource |
| [yandex_iam_service_account.sa-writer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account_key.sa-auth-key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_key) | resource |
| [yandex_iam_service_account_static_access_key.sa-writer-keys](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_iam_service_account_static_access_key.sa_static_key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_kms_secret_ciphertext.encrypted_pass](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_secret_ciphertext) | resource |
| [yandex_kms_secret_ciphertext.encrypted_s3_key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_secret_ciphertext) | resource |
| [yandex_kms_secret_ciphertext.encrypted_s3_secret](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_secret_ciphertext) | resource |
| [yandex_kms_symmetric_key.kms-key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_symmetric_key) | resource |
| [yandex_message_queue.log_queue_for_auditlog](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/message_queue) | resource |
| [yandex_message_queue.log_queue_for_falco](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/message_queue) | resource |
| [yandex_message_queue.log_queue_for_kyverno](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/message_queue) | resource |
| [yandex_resourcemanager_folder_iam_binding.binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_binding) | resource |
| [yandex_resourcemanager_folder_iam_binding.create_funct](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_binding) | resource |
| [yandex_resourcemanager_folder_iam_member.send_queue](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.upload_logs](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_storage_bucket.es-bucket](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket) | resource |
| [archive_file.function_export](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.function_pusher](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [yandex_iam_service_account.bucket_sa](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/iam_service_account) | data source |
| [yandex_kubernetes_cluster.my_cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/kubernetes_cluster) | data source |
| [yandex_resourcemanager_folder.my_folder](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/resourcemanager_folder) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auditlog_enabled"></a> [auditlog\_enabled](#input\_auditlog\_enabled) | AUDIT LOG | `bool` | n/a | yes |
| <a name="input_auditlog_worker_chart_name"></a> [auditlog\_worker\_chart\_name](#input\_auditlog\_worker\_chart\_name) | The name of the auditlog worker helm release | `string` | n/a | yes |
| <a name="input_auditlog_worker_namespace"></a> [auditlog\_worker\_namespace](#input\_auditlog\_worker\_namespace) | The namespace in which the worker chart will be deployed. | `string` | n/a | yes |
| <a name="input_auditlog_worker_replicas_count"></a> [auditlog\_worker\_replicas\_count](#input\_auditlog\_worker\_replicas\_count) | Count of replicas for audit worker. | `number` | n/a | yes |
| <a name="input_auditlogs_prefix"></a> [auditlogs\_prefix](#input\_auditlogs\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | The Yandex.Cloud cloud id. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The Yandex.Cloud K8s cluster name. | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exists. | `bool` | n/a | yes |
| <a name="input_elastic_pw"></a> [elastic\_pw](#input\_elastic\_pw) | Elastic Server | `string` | n/a | yes |
| <a name="input_elastic_server"></a> [elastic\_server](#input\_elastic\_server) | n/a | `string` | n/a | yes |
| <a name="input_elastic_user"></a> [elastic\_user](#input\_elastic\_user) | n/a | `string` | n/a | yes |
| <a name="input_fakeeventgenerator_enabled"></a> [fakeeventgenerator\_enabled](#input\_fakeeventgenerator\_enabled) | n/a | `bool` | n/a | yes |
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | FALCO | `bool` | n/a | yes |
| <a name="input_falco_helm_namespace"></a> [falco\_helm\_namespace](#input\_falco\_helm\_namespace) | The namespace in which the helm will be deployed. | `string` | n/a | yes |
| <a name="input_falco_prefix"></a> [falco\_prefix](#input\_falco\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_falco_version"></a> [falco\_version](#input\_falco\_version) | FALCO Helm | `string` | n/a | yes |
| <a name="input_falco_worker_chart_name"></a> [falco\_worker\_chart\_name](#input\_falco\_worker\_chart\_name) | The name of the falco worker helm release | `string` | n/a | yes |
| <a name="input_falco_worker_namespace"></a> [falco\_worker\_namespace](#input\_falco\_worker\_namespace) | The namespace in which the worker chart will be deployed. | `string` | n/a | yes |
| <a name="input_falco_worker_replicas_count"></a> [falco\_worker\_replicas\_count](#input\_falco\_worker\_replicas\_count) | Count of replicas for falco worker. | `number` | n/a | yes |
| <a name="input_falcosidekick_version"></a> [falcosidekick\_version](#input\_falcosidekick\_version) | n/a | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The Yandex.Cloud folder id. | `string` | n/a | yes |
| <a name="input_kyverno_enabled"></a> [kyverno\_enabled](#input\_kyverno\_enabled) | KYVERNO | `bool` | n/a | yes |
| <a name="input_kyverno_helm_namespace"></a> [kyverno\_helm\_namespace](#input\_kyverno\_helm\_namespace) | The namespace in which the helm will be deployed. | `string` | n/a | yes |
| <a name="input_kyverno_policies_version"></a> [kyverno\_policies\_version](#input\_kyverno\_policies\_version) | n/a | `string` | n/a | yes |
| <a name="input_kyverno_prefix"></a> [kyverno\_prefix](#input\_kyverno\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_kyverno_version"></a> [kyverno\_version](#input\_kyverno\_version) | KYVERNO Helm | `string` | n/a | yes |
| <a name="input_kyverno_worker_chart_name"></a> [kyverno\_worker\_chart\_name](#input\_kyverno\_worker\_chart\_name) | The name of the kyverno worker helm release | `string` | n/a | yes |
| <a name="input_kyverno_worker_namespace"></a> [kyverno\_worker\_namespace](#input\_kyverno\_worker\_namespace) | The namespace in which the worker chart will be deployed. | `string` | n/a | yes |
| <a name="input_kyverno_worker_replicas_count"></a> [kyverno\_worker\_replicas\_count](#input\_kyverno\_worker\_replicas\_count) | Count of replicas for kyverno worker. | `number` | n/a | yes |
| <a name="input_log_bucket_name"></a> [log\_bucket\_name](#input\_log\_bucket\_name) | S3 Bucket Variables | `string` | n/a | yes |
| <a name="input_podSecurityStandard"></a> [podSecurityStandard](#input\_podSecurityStandard) | n/a | `string` | `"restricted"` | no |
| <a name="input_policy_reporter_version"></a> [policy\_reporter\_version](#input\_policy\_reporter\_version) | n/a | `string` | n/a | yes |
| <a name="input_s3_expiration"></a> [s3\_expiration](#input\_s3\_expiration) | Enable or disable delete indicies backup from bucket after days | `map(string)` | <pre>{<br>  "days": 10,<br>  "enabled": true<br>}</pre> | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | functions.invoker, storage.editor, ymq.editor | `string` | n/a | yes |
| <a name="input_set"></a> [set](#input\_set) | Additional values set | `map(any)` | `{}` | no |
| <a name="input_set_sensitive"></a> [set\_sensitive](#input\_set\_sensitive) | Additional sensitive values set | `map(any)` | `{}` | no |
| <a name="input_timer_for_mq"></a> [timer\_for\_mq](#input\_timer\_for\_mq) | Timer for add permission for create mq | `string` | `"10s"` | no |
| <a name="input_validationFailureAction"></a> [validationFailureAction](#input\_validationFailureAction) | n/a | `string` | `"audit"` | no |
| <a name="input_value"></a> [value](#input\_value) | Values for the chart. | `string` | `""` | no |
| <a name="input_worker_docker_image"></a> [worker\_docker\_image](#input\_worker\_docker\_image) | Worker Settings | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_folder_id"></a> [folder\_id](#output\_folder\_id) | n/a |
| <a name="output_log_bucket_name"></a> [log\_bucket\_name](#output\_log\_bucket\_name) | n/a |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | n/a |
