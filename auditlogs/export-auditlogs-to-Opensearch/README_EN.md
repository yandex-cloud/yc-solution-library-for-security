# Collection, monitoring and analysis of Yandex Cloud audit logs in Opensearch

![image](https://user-images.githubusercontent.com/85429798/184665197-01f0cbca-78f3-4b32-90f1-ee6a4fa71d8e.png)

## Version

**Version-1.1**
- Changelog:
- Docker images:
    - `cr.yandex/sol/s3-opensearch-importer:1.1`

## Solution Description
The solution allows you to collect, monitor and analyze Yandex.Cloud audit logs (Audit Trails) in Opensearch from the following sources:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)

> The solution is constantly updated and maintained by the Yandex.Cloud Security team.

> Important! By default, this construct suggests deleting files after being subtracted from the bucket, but you can simultaneously store Audit Trails audit logs in S3 on a long-term basis and send them to Elastic. To do this, you need to create two Audit Trails in different S3 buckets:. The first bucket will be used for storage only. The second bucket will be used for integration with Opensearch

## What the solution does
- ☑️ Sends data to an existing Opensearch cluster (if you don't have an Opensearch cluster, use the installation instructions at the end of the page)
- ☑️ Deploys COI Instance with container based on s3-elk-importer image (`cr.yandex/sol/s3-opensearch-importer:latest`)
- ☑️ Upload Security Content to Opensearch (Dashboards, Detection Rules (with alerts), etc.)
- ☑️ Provides continuous delivery of json files with audit logs from Yandex Object Storage (Audit Trails) to Opensearch
- ☑️ Creates indexes on two replicas, configures a basic rollover policy (create new indexes every thirty days or when 50GB is reached), for further tuning in terms of data high availability and for configuring data snapshots in S3 - see [recommendations] (./CONFIGURE -HA.md).

## Solution diagram
<img width="786" alt="image" src="https://user-images.githubusercontent.com/85429798/184668940-295e5e53-615d-434a-8e03-7396d00e0781.png">


## Security Content
**Security Content** - Opensearch objects that are automatically loaded by the solution. All content is developed taking into account the experience of the Yandex.Cloud Security team and based on the experience of Cloud Clients.

Contains the following Security Content:
- Dashboard showing all use cases and useful statistics
- A set of Saved Queries for easy search of Security events
- An example of Alert for which alerts are configured (The client himself needs to specify the purpose of notifications)
- All interesting event fields are converted to the [Elastic Common Schema (ECS)] format (https://www.elastic.co/guide/en/ecs/current/index.html), full mapping table in the [Object description] file (https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов%20eng.docx) 

Detailed description in the file [ECS-mapping.docx](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/ ECS-mapping_new.pdf)

## Content update process
Coming soon..to the next version

## Installing the solution with Terraform

To install using terraform, go to the [terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/add-opensearch-solution/auditlogs/export-auditlogs-to- opensearch/terraform)

Based on the results of executing the tf script and the manual actions indicated below, audit trails events from the cloud will be loaded into the opensearch specified by you and security content (dashboard, filters, mapping etc.) will be loaded to work with them

As a result of the installation, you will have a tenant "at-tenant", in which all objects are located

## Set up Alerts and Destination
Alerting and response rules in Opensearch is done using the [Alerting] mechanism(https://opensearch.org/docs/latest/monitoring-plugins/alerting/index/)

Our solution already loads the monitor example, you can take it as an example to start and make alerts by analogy. Go to the Alerting - Monitors tab and find "test" there. Press the edit button, scroll down and expand the triggers tab and enter an action in it. Select a pre-created [notification] channel there (https://opensearch.org/docs/latest/notifications-plugin/index/) (for example, slack)


## Install Openasearch
To install opensearch, you can use the official documentation. For example [install with docker](https://opensearch.org/docs/2.1/opensearch/install/index/)

To set up TLS in opensearch dashboard, use [instruction](https://opensearch.org/docs/2.1/dashboards/install/tls/)

To generate a self-signed SSL certificate, use [instruction](https://opensearch.org/docs/2.1/security-plugin/configuration/generate-certificates/)
Or upload your own certificate

Here are test files for installing opensearch in the [deploy-of-opensearch] section(https://github.com/yandex-cloud/yc-solution-library-for-security/tree/add-opensearch-solution/auditlogs/ export-auditlogs-to-opensearch/deploy-of-opensearch)

p.s: don't forget to give the necessary file permissions with the certificate and key

## Recommendations for configuring retention, rollover and snapshots:

[Recommendations for configuring retention, rollover and snapshots](./CONFIGURE-HA.md)
