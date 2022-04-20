## Yandex.Cloud: Analyzing K8s security logs in ELK: audit logs, Policy Engine, Falco 

![image](https://user-images.githubusercontent.com/85429798/137449451-eaa3a4ec-5a79-4fc5-8e7e-bd222c78b714.png)

![Dashboard](https://user-images.githubusercontent.com/85429798/130331405-26a909ae-0171-47b2-93a2-c656632d262c.png)

<img width="1403" alt="1" src="https://user-images.githubusercontent.com/85429798/133788731-3c410508-3539-4ba0-b873-85ae55d58b87.png">

![2](https://user-images.githubusercontent.com/85429798/133788762-75152c1a-ad93-4291-999d-7fc0739d2438.png)

# Version

**Version-2.0**
- Changelog:
    - Changed the method of deployment. Deprecation of virtual machines as a worker engine to deployments in k8s. Thanks to "Hilbert Team" for contribution
    <a href="https://kubernetes.io/">
    <img src="https://storage.yandexcloud.net/9863c845-4d2b-4a09-a7dc-84118e8b892a-ht-logo/HT%20Logo.png"
         alt="Kubernetes logo" title="Kubernetes" height="115" width="115" />
</a></br>
- Docker images:
    - `cr.yandex/sol/k8s-events-siem-worker:2.0.0`.

**Version-2.0**
- Changelog:
    - Added support for automatic Kyverno installation with policies in the audit mode. 
- Docker images:
    - `cr.yandex/sol/k8s-events-siem-worker:1.1.0`.

# Table of contents

- [Description](#description)
- [Link to the solution "Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"](#link-to-solution-"Collecting-monitoring-and-analyzing-audit-logs-in-Yandex-Managed-Service-for-Elasticsearch-(ELK)")
- [Generic diagram](#generic-diagram)
- [Terraform description](#terraform-description)
- [Content update process](#content-update-process)
- [Optional manual actions](#optional-manual-actions)


## Description 
Here are the out-of-the-box features of the solution:
☑️ Collect [K8s audit logs](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/).
- ☑️ Install [Falco](https://falco.org/) and collect its [Alerts](https://falco.org/docs/alerts/) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/).
- ☑️ Install [Kyverno](https://kyverno.io/) with the [Pod Security Standards (Restricted)](https://kyverno.io/policies/?policytypes=Pod%2520Security%2520Standards%2520%28Restricted%29) policies in the audit mode and collect its [Alerts (Policy Reports)](https://kyverno.io/docs/policy-reports/) using [Policy Reporter](https://github.com/kyverno/policy-reporter).
- ☑️ Import Security Content: dashboards, detection rules, and so on (see the Security Content section) in [Managed ELK SIEM](https://cloud.yandex.ru/docs/managed-elasticsearch/) to enable analysis and response to information security events. 
- ☑️ This also includes importing Security Content for [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/) (in the enforce mode). You can install OPA Gatekeeper manually if needed.
- ☑️ Create indexes in two replicas, set up the basic rollover policy (creating of new indexes every thirty days or when 50 GB are reached) to enable provisioning of high data availability and to set up data snapshots in S3, see [recommendations](../export-auditlogs-to-ELK_main/CONFIGURE-HA.md). 

## Link to the solution "Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"
The solution ["Collecting, monitoring, and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)"](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main) contains information on how to install Yandex Managed Service for Elasticsearch (ELK) and collect logs from Audit Trails in it.


## Generic diagram 

![image](https://user-images.githubusercontent.com/85429798/164211865-5f95498a-3778-47a9-bb82-cb43110836c4.png)

## Description of imported ELK (Security Content) object
See a detailed description of the objects [here](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf).

## Terraform description 

The solution consist of terraform module:
- It accepts the following input: 
    - `folder_id`: The ID of the folder where the cluster is hosted.
    - `cloud_id`: The ID of the cloud where the cluster is hosted.
    - `cluster_name`: The name of the Kubernetes cluster.
    - `elastic_server`: The FQDN address of the ELK installation
    - `elastic_pw` and `elastic_user`: The ELK user credentials for event import
    - `service_account_id`: The ID of the service account that can write to the bucket and has the *ymq.admin* role.
    - `log_bucket_name`: The name of the bucket that will create module to save logs to.
    - `auditlog_enabled`: *true* or *false* (enables/disables sending of K8s audit logs to ELK).
    - `falco_enabled`: *true* or *false* (enables/disables sending of Falco alerts to ELK).
    - `kyverno_enabled`: *true* or *false* — (enables/disables sending of Kyverno alerts to ELK).
- Functionality: 
    - Create a static key for the service account.
    - Create a function and a trigger for writing cluster logs to S3.
    - Install Falco and pre-configured falcosidekick that will send logs to S3.
    - Install Kyverno and pre-configured [Policy Reporter](https://github.com/kyverno/policy-reporter) that will send logs to S3.
    - Create YMQ queues with log file names in S3.
    - Create functions to push file names from S3 to YMQ.
    - Create triggers for interaction between queues and functions.
    - Create deployments in k8s with worker containers that import events from S3 to ELK.

#### Prerequisites:
- :white_check_mark: Cluster Managed K8s.
- :white_check_mark: Managed ELK.
- :white_check_mark: A service account that can write to the bucket and has the *ymq.admin* role.


#### Example of calling modules:
See the example of calling modules in [/examples/README.md](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_k8s/examples/README.md)


## Content update process
We recommend subscribing to this repository to receive update notifications.

For content updates, make sure that you are running the latest available image version:
`cr.yandex/sol/k8s-events-siem-worker:latest`

You can update the container as follows:
You can re-create the deployments in k8s via Terraform (change worker_docker_image env in tfvars and run `terraform apply`).

## Optional manual actions
#### Installing OPA Gatekeeper (Helm)
If you prefer OPA Gatekeeper to Kyverno, set the value `kyverno_enabled` to *false* when calling the module, then run the manual installation:
- Install OPA Gatekeeper [using Helm](https://open-policy-agent.github.io/gatekeeper/website/docs/install/#deploying-via-helm).
- Select and install the required constraint template and constraint from [gatekeeper-library](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy).
- [Installation example](https://github.com/open-policy-agent/gatekeeper-library#usage).

## Recommendations for setting up retention, rollover, and snapshots:

[Recommendations for setting up retention, rollover, and snapshots](../export-auditlogs-to-ELK_main/CONFIGURE-HA.md)
