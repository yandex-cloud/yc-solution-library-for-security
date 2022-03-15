# 🔐 Yandex.Cloud Security Solution Library

**Yandex.Cloud Security Solution Library** is a set of examples and recommendations collected in a public repository on GitHub. Its purpose is to help companies build a secure infrastructure in the cloud and meet the requirements of various regulators and standards. Yandex.Cloud team has selected the most common tasks that arise when building security in the cloud. They have tested and described relevant scenarios in detail.

#### Brief webinar 
[![image](https://user-images.githubusercontent.com/85429798/146542425-b250c494-9a3c-4744-897d-5f65849355d5.png)](https://www.youtube.com/watch?v=WZOB9ow0WrA)


#### ☑️ Yandex.Cloud Security Checklist
Checklist for security in the Yandex.Cloud infrastructure

https://cloud.yandex.ru/docs/overview/security/domains/checklist

# List of solutions
- 🕸 Network security
  - [Example of setting up Security Groups (dev/stage/prod): Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/segmentation)
  - [Example of installing a VM instance with a firewall (NGFW): Check Point](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/checkpoint-1VM)
  - [Example of installing two VM instances with an NGFW Check Point: **Active-Active**](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/network-sec/checkpoint-2VM_active-active/README.md)
  - [Example of installing two NGFW Check Point VMs: **Active-Passive**](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/network-sec/checkpoint-2VM_active-passive/README.md)
  - [An example of creating a site-to-site VPN connection to Yandex.Cloud: Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/vpn)
- 🔑 Authentication and access control
  - [IAM module with usage examples](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auth_and_access/iam#identity-and-access-management-iam-terraform-module-for-yandexcloud)
- 🦠 Protection against malicious code
  - [Deploying Kaspersky Antivirus in Yandex.Cloud (Compute Instance, COI)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/malware-defense/kaspersy-install-in-yc)
- 🐞 Vulnerability management
  - [Fault-tolerant operation of PT Application Firewall based on Yandex.Cloud](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/unmng-waf-ptaf-cluster)
  - [Installing a vulnerable web application (DVWA) in Yandex.Cloud using Terraform for Managed WAF testing](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/vulnerable-web-app-waf-test)
- 🔏 Data encryption and key and secret management
  - [Encrypting secrets with KMS when transferring the keys to the COI VM container Yandex.Cloud: Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/encrypt_and_keys/terraform%2BKMS%2BCOI)
  - [Encrypting a VM disk in the cloud using YC KMS](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/encrypt_and_keys/encrypt_disk_VM)
- 🔎 Collecting, monitoring, and analyzing audit logs
  - [Collecting, monitoring and analyzing audit logs in Yandex Managed Service for Elasticsearch (ELK)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main)
  - [Collecting, monitoring, and analyzing audit logs in an external SIEM ArcSight](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ArcSight)
  - [Collecting, monitoring, and analyzing audit logs in an external Splunk](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-Splunk)
  - [Use cases and important security events in audit logs](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/_use_cases_and_searches)
  - [Trails-function-detector: Alerts and response to Information Security events in Audit Trails using Cloud Logging and Cloud Functions + Telegram](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/trails-function-detector)
  - [Monitoring Audit Trails and events in Yandex Cloud Monitoring](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/trail_monitoring)
- 👮 Secure configuration
  - [Example of a secure configuration for Yandex Cloud Object Storage: Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/configuration/hardening_bucket)
  - (Скоро) запрет доступа к метадате
##
<a href="https://kubernetes.io/">
    <img src="https://github.com/magnologan/awesome-k8s-security/blob/master/logo.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="50" />
</a></br>

- Kubernetes security
  - Authentication and access control in Managed Kubernetes:
    - [Example of setting up role-based models and policies in Yandex Managed Service for Kubernetes](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/auth_and_access/role-model-example)
  - Collecting, monitoring, and analyzing audit logs:
    - [Analyzing K8s security logs in ELK: audit logs, Policy Engine, Falco](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_k8s)
    - [Exporting Cilium Flow Logs to Object Storage (S3)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/cilium-s3)
  - Data encryption and key/secret management in Managed Kubernetes
    - [Secret Management with Secret Manager (Lockbox, Vault)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/encrypt_and_keys/secret-management)
  - Secure configuration of Managed Kubernetes:
    - [Osquery and kubequery in K8s: Osquery (protecting K8s nodes), kubequery (analyzing the configuration of the entire K8s)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/osquery-kubequery)
  - CVE mitigations:
    - [CVE-2022-0185](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/cve-quickfix/CVE-2022-0185)
    - [CVE-2021-4034](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/cve-quickfix/CVE-2021-4034)
  - [Feature comparison table of k8s security solution](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/choice_of_solutions)
  - [Starboard integration with Yandex Cloud Container Registry to scan running images](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/starboard_and_yc-cr)

##
<a href="https://kubernetes.io/">
    <img src="https://logowik.com/content/uploads/images/gitlab8368.jpg"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="50" />
</a></br>

- CI/CD Security
  - Secure CI/CD на базе Managed GitLab:
    - [Webinar+materials: Detection of Log4shell and other vulnerabilities in CI / CD based on Managed GitLab](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/secure_ci_cd/secure_ci_cd_with_webinar):
      - [Vulnerability detection in CI/CD (Ultimate license)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/secure_ci_cd/secure_ci_cd_with_webinar/ultimate_secure_ci_cd)
      - [Vulnerability detection in CI/CD (Free license)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/secure_ci_cd/secure_ci_cd_with_webinar/free_secure_ci_cd)
      - [Security in Gtilab instance check-list](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/secure_ci_cd/secure_ci_cd_with_webinar/gitlab_instance_sec_checklist)

#
<a href="https://kubernetes.io/">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Telegram_2019_Logo.svg/1200px-Telegram_2019_Logo.svg.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="50" />
</a></br>



# Feedback 
- Improvements, bugs, contribute: Please start using github issue/pr
- Questions, wishes, consultations: Write to us in telegram https://t.me/YandexCloudSecurity

#### Reference architecture
![Refer_arc](https://user-images.githubusercontent.com/85429798/132501079-0bd89876-2cc9-405b-aac3-ea65ac1fb6d2.png)
