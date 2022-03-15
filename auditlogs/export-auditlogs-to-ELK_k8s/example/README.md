## Terraform test script 

Prerequisites:
- ✅ Cluster Managed K8s.
- ✅ Managed ELK.
- ✅ A service account that can write to the bucket and has the *ymq.admin* role.
- ✅ Object Storage Bucket.
- ✅ A subnet for deploying a VM with NAT enabled.

##

1) Fill out the fields in the main.tf file.
2) Run:

```
terraform init
terraform apply
```

```
Example of calling modules:
//Calling the security-events-to-storage-exporter module
module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # path to the module

    folder_id = "xxxxxx" // The folder ID of the K8s cluster (yc managed-kubernetes cluster get --id <cluster ID> --format=json | jq  .folder_id)

    cluster_name = "k8s-cluster" // The name of the cluster

    log_bucket_service_account_id = "xxxxxx" // The ID of the Service Account (it must have the roles ymq.admin and "write to bucket")
    
    log_bucket_name = "k8s-bucket" // You can use the value from the deploy config
    # function_service_account_id = "hh" // An optional ID of the service account that calls the functions (if omitted, the function is called on behalf of log_bucket_service_account_id)
}


//Calling the security-events-to-siem-importer module
module "security-events-to-siem-importer" {
    source = "../security-events-to-siem-importer/" # path to the module

    folder_id = module.security-events-to-storage-exporter.folder_id 
    
    service_account_id = module.security-events-to-storage-exporter.service_account_id
    
    auditlog_enabled = true // Send K8s auditlog to ELK
    
    falco_enabled = true // Install Falco and send its alerts to ELK

    kyverno_enabled = true // Install Kyverno and send its alerts to ELK

    log_bucket_name = module.security-events-to-storage-exporter.log_bucket_name

    elastic_server = "https://c-xxx.rw.mdb.yandexcloud.net " // The ELK URL https://c-xxx.rw.mdb.yandexcloud.net (you can use the value from the module.yc-managed-elk.elk_fqdn module)

    coi_subnet_id = "xxxxxx" // The ID of the subnet where the VM with the container will be deployed (be sure to enable NAT)

    elastic_pw = var.elk_pw // Run the command: export TF_VAR_elk_pw=<ELK PASS> (replace ELK PASS with your value) // The password for the ELK account (you may use the value from the module.yc-managed-elk.elk-pass module)
    
    elastic_user = "admin" // The name of the ELK account
}
```
