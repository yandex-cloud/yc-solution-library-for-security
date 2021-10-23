# "cilium-s3" Export flow logs of Cilium to Yandex Cloud Object Storage

# Version

**Version-1.0**
- Changelog:
    - First version
- Docker images:
    - `cr.yandex/crpjfmfou6gflobbfvfv/cilium-s3:1`
- Helm chart:
    - `cr.yandex/crpjfmfou6gflobbfvfv/cilium-s3-chart:0.1.0`

## Solution Description
Connects via gRPC to hubble-relay and sends netflow events to Object Storage
Then you can pick up these events from Object Storage to any SIEM using [GeeseFS] (https://cloud.yandex.ru/docs/storage/tools/geesefs) or other aws compatible plugins

Or using prepared Object Storage integrations in the following SIEMs:
- [Object storage to Splunk](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-Splunk)
- Cilium flow logs to Elasticsearch Скоро!!!

## Installing with helm

#### Prerequisites 
- :white_check_mark: Yandex Managed Service for Kubernetes® [with Cilium CNI enabled](https://cloud.yandex.ru/docs/managed-kubernetes/quickstart#kubernetes-cluster-create)
- :white_check_mark: [Object Storage Bucket](https://cloud.yandex.ru/docs/storage/quickstart)
- :white_check_mark: [Created static keys for service account](https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key)
- :white_check_mark: [Installed Helm client](https://helm.sh/ru/docs/intro/install/)

#### Install helm-chart 

Install helm hart by replacing the values with your own (specified in the prerequisites)

```Python
helm install cilium-s3-chart oci://cr.yandex/crpjfmfou6gflobbfvfv/cilium-s3-chart --version 0.1.0 --namespace cilium-s3 --create-namespace \
--set yandex.secretaccesskey=<your-secretaccesskey> \
--set yandex.bucket=<your-Bucket-name> \
--set yandex.accesskeyid=<your-accesskeyid> \
--set yandex.prefix=<your-secretaccesskey> (например:k8s-cilium-flow-logs/cluster-id-1232145gfg) 

```