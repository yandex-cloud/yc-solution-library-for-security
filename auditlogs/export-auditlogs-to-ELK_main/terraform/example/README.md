## Terraform test script 

1) Fill out the variables.tf file.
2) Run:

```
terraform init
terraform apply
```

The module performs the following actions:
1) Creates a VPC network 
2) Creates three subnets (one for each availability zone: a, b, c).
3)  Creates a service account with the *storage.admin* role to create a Bucket (Object Storage).
4) Creates a static key for this SA.
5) Creates a bucket.
6) Service account with permissions `storage.editor` for bucket jobs
7) Cluster ElasticSearch from module `yc-managed-elk`
8) Container and COI-instance from module `yc-elastic-trail`

When you exit the console, you'll see the DNS name of ELK Kibana and the password for the default admin user. To output the password, enter the `terraform output elk-pass` command.

After that, [create Audit Trails](https://cloud.yandex.ru/docs/audit-trails/quickstart) manually from the UI and specify the bucket created

> **Important:** Be sure to leave the trails bucket prefix empty or change this prefix in call of module `yc-elastic-trail` in the file `main.tf`.

> **Важно:** Then manually enable Egress NAT for subnet-a (go to the subnet settings, then click "Enable NAT" in the upper-right corner).