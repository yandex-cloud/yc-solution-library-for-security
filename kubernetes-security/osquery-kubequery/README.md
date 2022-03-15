# Osquery and kubequery in K8s
**MVP**

# Version-1.0

**Version-1.0**
- Changelog:
    - First version
- Docker images:
    - `cr.yandex/sol/osquery-ds:mvp`
- Helm chart:
    - `cr.yandex/sol/osquery-ds-yc:0.1.0`
    
## Task
    
Use **Osquery** and **kubequery** in a K8s cluster and send results to SIEM (ELK, Splunk).

## Introduction:

<a href="https://kubernetes.io/">
    <img src="https://engineering.fb.com/wp-content/uploads/2014/10/1_XC-k2QigREIwZnBpFZ4StA@2x.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="150" />
</a></br>

[Osquery](https://github.com/osquery/osquery) is a tool that allows you to get information about the OS in the format of [SQL queries](https://osquery.io/schema/current/#file_events). 

Tasks solved:

- [Query configs, OS/device settings, proccess, open ports, packets](https://github.com/osquery/osquery#what-is-osquery)
- [File Integrity Monitoring with osquery](https://osquery.readthedocs.io/en/stable/deployment/file-integrity-monitoring/)
- [Reading syslog with osquery](https://osquery.readthedocs.io/en/stable/deployment/syslog/)
- [Anomaly detection with osquery](https://osquery.readthedocs.io/en/stable/deployment/anomaly-detection/)
- [Process and socket auditing with osquery ((including eBPF)](https://osquery.readthedocs.io/en/stable/deployment/process-auditing/)
- [Collecting information about containers on the host](https://www.uptycs.com/blog/get-started-using-osquery-for-container-security)

##

<a href="https://kubernetes.io/">
    <img src="https://repository-images.githubusercontent.com/330738883/21226100-5c12-11eb-9223-9a51942d504e"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="90" />
</a></br>

[Kubequery](https://github.com/Uptycs/kubequery) is a tool from the creators of Osquery that lets you get information from the K8s cluster about it's current configuration:
-    API resources.
-    RBAC roles assigned.
-    Data about policies.
-    Data about secrets.

For more information about default SQL queries, see the [link](https://github.com/Uptycs/kubequery/blob/master/charts/kubequery/values.yaml#L41).

## Issues

- **Osquery has no publicly available examples of installation in K8s in the daemonset format.**
- **The tools don't have a built-in capacity to send results to SIEM (ELK, Splunk).**

## Solution diagram

![image](https://user-images.githubusercontent.com/85429798/143606481-7ccef674-61de-4097-8042-c7f9e9a66b5f.png)
source of image - https://github.com/Uptycs/kubequery

## Deployment

### Osquery

<a href="https://kubernetes.io/">
    <img src="https://engineering.fb.com/wp-content/uploads/2014/10/1_XC-k2QigREIwZnBpFZ4StA@2x.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="150" />
</a></br>

#### Installing Osquery in K8s

**Specifics of K8s installation**

- It makes sense to install Osquery on K8s nodes in the [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) format.
- For Osquery to run correctly, you must have access to the K8s node /proc directory and have the flag [hostPID=true](https://github.com/BishopFox/badPods/tree/main/manifests/hostpid), but as the test has shown, that's not enough, and when accessing the /proc host directory from inside the container, the container still has access only to its processes. This is because of the [/proc directory specifics](https://stackoverflow.com/questions/47072586/docker-access-host-proc).
- For this reason (and also based on the test results), we decided to: set for the container the following parameters: `hostNetwork`: *true*, `hostPID`: *true*, `hostIPC`: *true*, `hostPath`: *path: /*, and execute 'chroot' from the container to the host namespace. This entails risks associated with a privileged pod and going beyond the container. These risks can be minimized by a separate namespace with this container and a correct RBAC + Policy Engine, Network Policy, and others.

There are two ways to downgrade container privileges:
-    Install the Osquery agent not via K8s, but directly on the nodes (difficulties in administration).
-    One team mentions in their [article](https://developer.ibm.com/articles/monitoring-containers-osquery/) that they solved this task by developing a custom extension in [osquery-go](https://github.com/kolide/osquery-go/blob/master/README.md), changing its default folder from /proc to /host/proc, so you just need to mount this folder without any priviledges. **Research is needed**.

**Installing Osquery components in K8s**

<details>
<summary>Expand for viewing..........⬇️</summary>

**The prepared configuration includes:**

- Basic Osquery config with the following options enabled:
- Integrity control of critical K8s nodes files (according to CIS Benchmark).
- [Osquery packs](https://github.com/osquery/osquery/tree/master/packs) included: incident response, vuln-management;
- Proccess events enable.
- A configuration file with a script that checks for an Osquery binary on the K8s node and, if necessary, copies it and runs 
- Network Policies that, by default, prohibit all incoming and outgoing traffic for the Osquery namespace.

**Prerequisites:**

- A deployed cluster of [Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/quickstart).

**Installation using Helm:**

-    Download values.yaml:
```
helm inspect values oci://cr.yandex/sol/osquery-ds-yc --version 0.1.0 > values.yaml
```

-    If necessary, customize the configuration in the file or set parameters during installation.

-    Run installation with the parameters:
```
helm install osquery-ds-yc \
oci://cr.yandex/sol/osquery-ds-yc --version 0.1.0 \
 --namespace osquery \
--create-namespace \
-f values.yaml \
--set osqueryArgs="--verbose --disable_events=false --enable_file_events=true --disable_audit=false --audit_allow_config=true --audit_persist=true --audit_allow_process_events=true"
```

- * To enable eBPF proccess events, add the flag `--enable_bpf_events=true` and access the `bpf_process_events` table. Read more in the [docs](https://osquery.readthedocs.io/en/stable/deployment/process-auditing/)

**Installation with kubectl apply:**

-    Download the repository files:
```
git clone https://github.com/yandex-cloud/yc-solution-library-for-security.git 
```
-    Go to the folder:
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/osquery-install-daemonset/ 
```
-    If necessary, customize the files configmap-config.yaml and configmap-pack_conf.yaml.

-    Run the following commands:
```
kubectl apply -f ./ns.yaml 
kubectl apply -f ./
```

**TBD: Creating a Helm chart**

</details>

##

#### Sending results to SIEM
Sending results to SIEM is performed according to the scheme [Using a node logging agent](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-node-logging-agent)

#### Sending results to ELK

<a href="https://kubernetes.io/">
    <img src="https://oracle-patches.com/images/2020/03/05/estc-logo-vvedenie_large.jpg"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="90" />
</a></br>

<details>
<summary>Expand for viewing..........⬇️</summary>  

![image](https://user-images.githubusercontent.com/85429798/143606732-547cd5c6-35ed-4296-b0ca-fbb0e017da5c.png)

[Filebeat](https://www.elastic.co/beats/filebeat) is used to send data to ELK. Filebeat has a built-in [Osquery module](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-module-osquery.html). It's installed using [Helm chart](https://github.com/elastic/helm-charts/tree/main/filebeat).

**Prerequisites:**

- A deployed cluster of [Managed Service for ElasticSearch](https://cloud.yandex.ru/docs/managed-elasticsearch/operations/cluster-create).
- Credentials for the cluster.

**Installing components in K8s:**

- Go to the folder:
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/filebeat-helm/
```
- Download a certificate for Managed Elastic service (shared by all):
```
mkdir ~/.elasticsearch && \
wget  "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.elasticsearch/root.crt && \
chmod 0600 ~/.elasticsearch/root.crt
cp ~/.elasticsearch/root.crt ./elastic-certificate.pem
```
-    Create a secret with an ELK certificate in a K8s cluster:
```
kubectl create secret generic elastic-certificate-pem --from-file=./elastic-certificate.pem
```
-    Create a secret with ELK credentials in a K8s cluster (replace with your values):
```
kubectl create secret generic security-master-credentials --from-literal=username=admin --from-literal=password=P@ssword
```
-    Prepare an existing ./values.yaml file in the folder (edit).
```
Set the ELK name for the extraEnvs host:
extraEnvs:
      - name: "ELASTICSEARCH_HOSTS"
        value: "c-c9qfrs7u8i6g59dkb0vj.rw.mdb.yandexcloud.net:9200"

Edit the configuration file if needed.
```
-    Install the Helm chart with the modified Helm file named "values"
```
helm repo add elastic https://helm.elastic.co
helm install filebeat elastic/filebeat -f values.yaml
```
- Check for entries in the ELK database in the Filebeat-osquery index (create an index pattern).
- A Filebeat-osquery index will appear in Elastic.

- **TBD: Creating a separate dashboard in ELK for Osquery (installed packages, shell commands, open ports, OS versions, node versions, etc.).**

</details>

#### Sending results to Splunk

<a href="https://kubernetes.io/">
    <img src="https://cdn.f1ne.ws/userfiles/brown/142781.jpg"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="90" />
</a></br>

<details>
<summary>Expand for viewing..........⬇️</summary>  

![image](https://user-images.githubusercontent.com/85429798/143606623-1d3630aa-53e8-44dd-a619-a7b19d9dc925.png)

To send results to Splunk, use [fluentd splunk hec plugin](https://github.com/splunk/fluent-plugin-splunk-hec). It's installed using [helm-chart](https://github.com/splunk/splunk-connect-for-kubernetes/tree/develop/helm-chart/splunk-connect-for-kubernetes/charts/splunk-kubernetes-logging). 

**Prerequisites:**

-    Splunk has been deployed.
-    [HTTP Event Collector](https://docs.splunk.com/Documentation/SplunkCloud/8.2.2105/Data/UsetheHTTPEventCollector#Configure_HTTP_Event_Collector_on_Splunk_Enterprise) has been configured.
-    You have a HEC token for sending events.

**Installing components in K8s**

-    Go to the folder:
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/fluentsplunk-helm/
```
-    Prepare an existing ./values.yaml file in the folder (edit) or download the [original one](https://github.com/splunk/splunk-connect-for-kubernetes/blob/develop/helm-chart/splunk-connect-for-kubernetes/charts/splunk-kubernetes-logging/values.yaml).
-    Set the Splunk host name:
```
splunk:
  hec:
    host: 51.250.7.127 (specify your value)
```
-    Install a Helm chart specifying the ./values.yaml file, your HEC Token, and SSL settings:
```
helm install my-splunk-logging -f values.yaml --set splunk.hec.insecureSSL=true --set splunk.hec.token=<your token> --set splunk-kubernetes-logging.fullnameOverride=splunk-logging https://github.com/splunk/splunk-connect-for-kubernetes/releases/download/1.4.5/splunk-kubernetes-logging-1.4.5.tgz
```

</details>

##

### Kubequery

<a href="https://kubernetes.io/">
    <img src="https://repository-images.githubusercontent.com/330738883/21226100-5c12-11eb-9223-9a51942d504e"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="90" />
</a></br>

#### Installing kubequery in K8s

**Specifics of installation in K8s:** kubequery is installed in K8s as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) using a [Helm chart](https://github.com/Uptycs/kubequery#helm).

Kubequery results are written to the pod folder: /opt/uptycs/logs/osqueryd.results.log*

To send kubequery results to SIEM, edit the configuration of Helm chart by adding an additional sidecar container with the SIEM agent. 

[Diagram of a sidecar container with a logging agent.](https://kubernetes.io/docs/concepts/cluster-administration/logging/#sidecar-container-with-a-logging-agent)  

#### Installing kubequery with Filebeat sidecar to send data to ELK

<details>
<summary>Expand for viewing..........⬇️</summary>  

![image](https://user-images.githubusercontent.com/85429798/143607391-b0c5c2ee-4556-429b-a3e4-bb17e2dcdda5.png)

-    Go to the folder:
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/kubequery/kubequery-with-elastic-filebeat/
```
-    Create a namespace:
```
kubectl create ns kubequery
```
-    Download a certificate for Managed Elastic service (shared by all):
```
mkdir ~/.elasticsearch && \
wget  "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.elasticsearch/root.crt && \
chmod 0600 ~/.elasticsearch/root.crt
cp ~/.elasticsearch/root.crt ./elastic-certificate.pem
```
-    Create a secret with an ELK certificate in the K8s cluster:
```
kubectl create secret generic elastic-certificate-pem --from-file=./elastic-certificate.pem -n kubequery
```
-    Create a secret with ELK credentials in the K8s cluster (replace with your values):
```
kubectl create secret generic security-master-credentials --from-literal=username=admin --from-literal=password=P@ssword -n kubequery
```
-    In the ./configmap-filebeat.yaml file, specify the value of `output.elasticsearch`: *hosts: "c-c9qfrs7u8i6g59dkb0vj.rw.mdb.yandexcloud.net:9200"* (your value).
-    Download Helm chart files using the command:
```
git clone https://github.com/Uptycs/kubequery.git
```
-    Copy the prepared files to the chart folder:
```
cp ./*.yaml ./kubequery/charts/kubequery/templates/
```
-    Delete the ns creation file from the chart folder:
```
rm ./kubequery/charts/kubequery/templates/namespace.yaml
```
-    In the ./kubequery/charts/kubequery/values.yaml file, specify the value of the cluster name `cluster`: *mycluster*.
-    Install Helm chart from a local working folder:
```
helm install my-kubequery ./kubequery/charts/kubequery/ 
```
A filebeat-kubequery index will appear in Elastic.

**TBD: Creating a Helm chart for convenience and contributing it to kubequery**

</details>

#### Installing kubequery with fluentd sidecar to send data to Splunk

<details>
<summary>Expand for viewing..........⬇️</summary> 

![image](https://user-images.githubusercontent.com/85429798/143606787-4ef0c6e9-7595-4293-958d-7e06d10abbe5.png)

- Go to the folder:
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/kubequery/kubequery-with-splunk/
```
-    Create a namespace:
```
kubectl create ns kubequery
```
-    Create a secret to store an HEC token:
```
kubectl create secret generic splunk-hec-secret --from-literal=splunk_hec_token=<your token> -n kubequery
```
-    In the ./configmap-fluentd.yaml file, specify value for `hec_host` -- *51.250.7.127* (your address) and for `host`  — *my-cluster* (cluster name).
-    Download Helm chart using the command:
```
git clone https://github.com/Uptycs/kubequery.git
```
-    Copy the prepared files to the chart folder:
```
cp ./*.yaml ./kubequery/charts/kubequery/templates/
```
-    Delete the ns creation file from the chart folder:
```
rm ./kubequery/charts/kubequery/templates/namespace.yaml
```
-    Install Helm chart from a local working folder:
```
helm install my-kubequery ./kubequery/charts/kubequery/ 
```

** TBD: Creating a Helm chart for convenience and contributing it to kubequery **

</details>
