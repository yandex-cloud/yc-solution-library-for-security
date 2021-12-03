# "cilium-s3" Export flow logs of Cilium to Yandex Cloud Object Storage

<img width="1081" alt="Снимок экрана 2021-10-23 в 20 40 23" src="https://user-images.githubusercontent.com/85429798/138566364-3f6beb5b-aab9-4bb3-8d14-c7f108aaa1d6.png">

<img width="607" alt="Снимок экрана 2021-10-23 в 20 38 08" src="https://user-images.githubusercontent.com/85429798/138566328-f1a32606-47aa-4a4d-bf68-a346d3c87a74.png">

<img width="607" alt="Снимок экрана 2021-10-23 в 20 38 08" src="https://user-images.githubusercontent.com/85429798/138566529-cf6aadb4-df28-4de1-83ce-360523a12588.png">



# Version

**Version-1.0**
- Changelog:
    - First version
- Docker images:
    - `cr.yandex/sol/cilium-s3:1`
- Helm chart:
    - `cr.yandex/sol/cilium-s3-chart:0.1.0`

## Solution Description
Connects via gRPC to hubble-relay and sends netflow events to Object Storage
Then you can pick up these events from Object Storage to any SIEM using [GeeseFS](https://cloud.yandex.ru/docs/storage/tools/geesefs) or other aws compatible plugins

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
helm install cilium-s3-chart oci://cr.yandex/sol/cilium-s3-chart --version 0.1.0 --namespace cilium-s3 --create-namespace \
--set yandex.secretaccesskey=<your-secretaccesskey> \
--set yandex.bucket=<your-Bucket-name> \
--set yandex.accesskeyid=<your-accesskeyid> \
--set yandex.prefix=<your-secretaccesskey> (например:k8s-cilium-flow-logs/cluster-id-1232145gfg) 

```

```
Helm values:
yandex:
-    accesskeyid: ""  # yandex access key
-    secretaccesskey: ""  # yandex secret access key
-    bucket: ""  # Yandex storage, bucket name
-    hubble_url: "hubble-relay.kube-system.svc.cluster.local:80" # Hubble-url
-    prefix: "k8s-cilium-flow-logs/" # Prefix of bucket folder
-    region: "ru-central1" # region of S3
-    endpoint: "https://storage.yandexcloud.net" # endpoint of S3
```
