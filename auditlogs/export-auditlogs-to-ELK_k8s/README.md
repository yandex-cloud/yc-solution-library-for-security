## Yandex.Cloud: Analyzing K8s security logs in ELK: audit logs, Policy Engine, Falco 

![image](https://user-images.githubusercontent.com/85429798/137449451-eaa3a4ec-5a79-4fc5-8e7e-bd222c78b714.png)

![Dashboard](https://user-images.githubusercontent.com/85429798/130331405-26a909ae-0171-47b2-93a2-c656632d262c.png)

<img width="1403" alt="1" src="https://user-images.githubusercontent.com/85429798/133788731-3c410508-3539-4ba0-b873-85ae55d58b87.png">

![2](https://user-images.githubusercontent.com/85429798/133788762-75152c1a-ad93-4291-999d-7fc0739d2438.png)

# Version

**Version-2.0**
- Changelog:
    - Added support for automatic Kyverno installation with policies in the audit mode. 
- Docker images:
    - `cr.yandex/crpjfmfou6gflobbfvfv/k8s-events-siem-worker:1.1.0`.

# Table of contents

- [Description](#description)
- [Link to the solution "Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"](#link-to-solution-"Collecting-monitoring-and-analyzing-audit-logs-in-Yandex-Managed-Service-for-Elasticsearch-(ELK)")
- [Generic diagram](#generic-diagram)
- [Description of imported ELK (Security Content) objects](#description of-imported-ELK-(Security-Content)-objects)
- [Terraform description](#terraform-description)
- [Content update process](#content-update-process)
- [Optional manual actions](#optional-manual-actions)


## Description 
Here are the out-of-the-box features of the solution:
☑️ Collect [K8s audit logs](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/).
- ☑️ Install [Falco](https://falco.org/) and collect its [Alerts](https://falco.org/docs/alerts/) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/).
- ☑️ Install [Kyverno](https://kyverno.io/) with the [Pod Security Policy (Restricted)](https://kyverno.io/policies/?policytypes=Pod%2520Security%2520Standards%2520%28Restricted%29) policies in the audit mode and collect its [Alerts (Policy Reports)](https://kyverno.io/docs/policy-reports/) using [Policy Reporter](https://github.com/kyverno/policy-reporter).
- ☑️ Import Security Content: dashboards, detection rules, and so on (see the Security Content section) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/) to enable analysis and response to information security events. 
- ☑️ This also includes importing Security Content for [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/) (in the enforce mode). You can install OPA Gatekeeper manually if needed.
- ☑️ Create indexes in two replicas, set up the basic rollover policy (creating of new indexes every thirty days or when 50 GB are reached) to enable provisioning of high data availability and to set up data snapshots in S3, see [recommendations](../export-auditlogs-to-ELK_main/CONFIGURE-HA.md). 

## Link to the solution "Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"
The solution ["Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main) contains information on how to install Yandex Managed Service for Elasticsearch (ELK) and collect logs from Audit Trails in it.


## Generic diagram 

![image](https://user-images.githubusercontent.com/85429798/137740249-a9b09aaf-13f3-4022-83fe-5ba45f6c8418.png)

## Description of imported ELK (Security Content) object
See a detailed description of the objects [here](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf).

## Terraform description 

The solution consists of two Terraform modules:
1) [security-events-to-storage-exporter](./security-events-to-storage-exporter) exports logs to S3.
- It accepts the following input: 
        - `folder_id`: The ID of the folder where the cluster is hosted.
    - `cluster_name`: The name of the Kubernetes cluster.
    - `log_bucket_service_account_id`: The ID of the service account that can write to the bucket and has the *ymq.admin* role.
    - `log_bucket_name`: The name of the bucket to save logs to.
    - `function_service_account_id`: The ID of the service account that will run the function (optional). If omitted, `log_bucket_service_account_id` is used.

- Functionality: 
    - Create a static key for the service account.
    - Create a function and a trigger for writing cluster logs to S3.
    - Install Falco and pre-configured falcosidekick that will send logs to S3.
       - Install Kyverno and pre-configured [Policy Reporter](https://github.com/kyverno/policy-reporter) that will send logs to S3.

2) [security-events-to-siem-importer](./security-events-to-siem-importer) imports logs into ELK.
- It accepts the following input: 
    - Several parameters from the module (`security-events-to-storage-exporter`) module.
    - `auditlog_enabled`: *true* or *false* (enables/disables sending of K8s audit logs to ELK).
    - 'falco_enabled`: *true* or *false* (enables/disables sending of Falco alerts to ELK).
    - 'kyverno_enabled`: *true* or *false* — (enables/disables sending of Kyverno alerts to ELK).
    - The FQDN address of the ELK installation.
    - The ID of the subnet where the VM instance with the importer container is being created.
    - The ELK user credentials for event import.

- Functionality: 
    - Create YMQ queues with log file names in S3.
    - Create functions to push file names from S3 to YMQ.
    - Create triggers for interaction between queues and functions.
    - Generate and write SSH keys to a file and to a VM.
    - Create VM instances based on COI ([Container Optimized Image](https://cloud.yandex.ru/docs/cos/concepts/)) with worker containers that import events from S3 to ELK.

#### Prerequisites:
- :white_check_mark: Cluster Managed K8s.
- :white_check_mark: Managed ELK.
- :white_check_mark: A service account that can write to the bucket and has the *ymq.admin* role.
- :white_check_mark: Object Storage Bucket.
- :white_check_mark: A subnet for deploying a VM with NAT enabled.


#### Example of calling modules:
See the example of calling modules in /example/main.tf 

```Python

//Calling the security-events-to-storage-exporter module

module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # path to the module

    folder_id = "xxxxxx" // The folder ID of the K8s cluster yc managed-kubernetes cluster get --id <cluster ID> --format=json | jq  .folder_id

    cluster_name = "k8s-cluster" // The name of the cluster

    log_bucket_service_account_id = "xxxxxx" // The ID of the Service Account (it must have the roles: ymq.admin and "write to bucket")
    
    log_bucket_name = "k8s-bucket" // You can use the value from the deploy config
    # function_service_account_id = "xx" // An optional ID of the service account that calls functions. If not set, the function is called on behalf of log_bucket_service_account_id
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

    elastic_server = "https://c-xxx.rw.mdb.yandexcloud.net " // The ELK URL "https://c-xxx.rw.mdb.yandexcloud.net" (you can use the value from the module.yc-managed-elk.elk_fqdn module)

    coi_subnet_id = "xxxxxx" // The ID of the subnet where the VM with the container will be deployed (be sure to enable NAT)

    elastic_pw = var.elk_pw // Run the command: export TF_VAR_elk_pw=<ELK PASS> (replace ELK PASS with your value) // The password for the ELK account (you may use the value from the module.yc-managed-elk.elk-pass module)
    
    elastic_user = "admin" // The name of the ELK account
}
    
```

## Content update process
We recommend subscribing to this repository to receive update notifications.

To get the latest content version, do the following:
- Keep the sync container up-to-date.
- Keep the Security content imported to Elasticsearch in the updated state.

For content updates, make sure that you are running the latest available image version:
`cr.yandex/crpjfmfou6gflobbfvfv/k8s-events-siem-worker:latest`

You can update the container as follows:
- You can re-create the deployed COI Instance with the container via Terraform (delete the COI Instance, run `terraform apply`).
- You can stop and delete the `falco-worker-*`, `kyverno-worker-*`, `audit-worker-*` containers, delete the `k8s-events-siem-worker` image, and restart the COI Instance. When it starts, a new image is downloaded and new containers are created.

You can update the Security content in Kibana (dashboards, detection rules, searches) by launching the `elk-updater` container:

```
docker run -it --rm -e ELASTIC_AUTH_USER='admin' -e ELASTIC_AUTH_PW='password' -e KIBANA_SERVER='https://xxx.rw.mdb.yandexcloud.net' --name elk-updater cr.yandex/crpjfmfou6gflobbfvfv/elk-updater:latest
```

## Optional manual actions
#### Installing OPA Gatekeeper (Helm)
If you prefer OPA Gatekeeper to Kyverno, set the value `kyverno_enabled` to *false* when calling the module, then run the manual installation:
- Install OPA Gatekeeper [using Helm](https://open-policy-agent.github.io/gatekeeper/website/docs/install/#deploying-via-helm).
- Select and install the required constraint template and constraint from [gatekeeper-library](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy).
- [Installation example](https://github.com/open-policy-agent/gatekeeper-library#usage).

## Recommendations for setting up retention, rollover, and snapshots:

[Recommendations for setting up retention, rollover, and snapshots](../export-auditlogs-to-ELK_main/CONFIGURE-HA.md)
