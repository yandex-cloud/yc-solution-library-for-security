## Deploying the example via Terraform

According to the results of executing the tf script and the manual actions indicated below, audit trails events from the cloud will be loaded into the opensearch specified by you and security content (dashboard, filters, mapping etc.) will be loaded.

1) Fill the `variables.tf` file with values for: opensearch_pass, opensearch_user, opensearch_address, folder_id, cloud_id, token. To install into an existing subnet, specify its id in the main.tf file in the coi_subnet_id variable (by default, a new network is created)
2) To fill in the token field, create a [key](https://cloud.yandex.ru/docs/iam/operations/authorized-key/create) for a service account for authentication in terraform or use your OAuth token yc
3) Run:

```
terraform init
terraform apply
```

The module performs the following actions:
1) Creates a VPC network 
2) Creates three subnets (one for each availability zone: a, b, c).
3) Creates a service account with the *storage.admin* role to create a Bucket (Object Storage).
4) Creates a static key for this SA.
5) Creates a bucket.
6) Service account with permissions `storage.editor` for bucket jobs
7) Container and COI instance from module for loading events and content

After that, [create Audit Trails](https://cloud.yandex.ru/docs/audit-trails/quickstart) manually from the UI and specify the bucket created

> **Important:** You must specify an empty prefix for the bucket, or change the prefix in the call in the `main.tf` file.

> **Important:** You must enable NAT on the created subnets.