# Checkov + Yandex Cloud

картинка + из презы

Оглавление

## Intro
**Checkov now supports Yandex Cloud terraform objects**.

[Checkov](https://github.com/bridgecrewio/checkov) is a static code analysis tool for infrastructure-as-code. 
It scans cloud infrastructure provisioned using Terraform, Terraform plan, Cloudformation, AWS SAM, Kubernetes, Helm charts,Kustomize, Dockerfile, Serverless, Bicep, OpenAPI or ARM Templates and detects security and compliance misconfigurations using graph-based scanning.

Installation and usage instructions are available on the [checkov page](https://github.com/bridgecrewio/checkov#getting-started)

картинка с рабочего успешного скана

## Information about checks for Yandex cloud
You can find all checks in [source code](https://github.com/bridgecrewio/checkov/tree/master/checkov/terraform/checks/resource/yandexcloud)

| № of check  | Description|
| ------------- | ------------- |
| CKV_YC_1  | "Ensure security group is assigned to database cluster."  |
| CKV_YC_2  | "Ensure compute instance does not have public IP."  |
| CKV_YC_3 | "Ensure storage bucket is encrypted." |

<details>
<summary>Expand for viewing all checks..........⬇️</summary>

| № of check  | Description|
| ------------- | ------------- |
| CKV_YC_1  | "Ensure security group is assigned to database cluster."  |
| CKV_YC_2  | "Ensure compute instance does not have public IP."  |
| CKV_YC_3 | "Ensure storage bucket is encrypted." |
| CKV_YC_4 | "Ensure compute instance does not have serial console enabled."  |
| CKV_YC_5  | "Ensure Kubernetes cluster does not have public IP address."  |
| CKV_YC_6 | "Ensure Kubernetes cluster node group does not have public IP addresses."  |
| CKV_YC_7 | "Ensure Kubernetes cluster auto-upgrade is enabled."  |
| CKV_YC_8  | "Ensure Kubernetes node group auto-upgrade is enabled."  |
| CKV_YC_9 | "Ensure KMS symmetric key is rotated."  |
| CKV_YC_10 | "Ensure etcd database is encrypted with KMS key." |
| CKV_YC_11  | "Ensure security group is assigned to network interface." |
| CKV_YC_12  | "Ensure public IP is not assigned to database cluster." |
| CKV_YC_13 | "Ensure cloud member does not have elevated access."  |
| CKV_YC_14 | "Ensure security group is assigned to Kubernetes cluster."  |
| CKV_YC_15 | "Ensure security group is assigned to Kubernetes node group." |
| CKV_YC_16  | "Ensure network policy is assigned to Kubernetes cluster." |
| CKV_YC_17  | "Ensure storage bucket does not have public access permissions."  |
| CKV_YC_18  | "Ensure compute instance group does not have public IP."  |
| CKV_YC_19  | "Ensure security group does not contain allow-all rules."  |
| CKV_YC_20  | "Ensure security group rule is not allow-all."  |
| CKV_YC_21 | "Ensure organization member does not have elevated access."  |
| CKV_YC_22 | "Ensure compute instance group has security group assigned."  |
| CKV_YC_23 | "Ensure folder member does not have elevated access." |
| CKV_YC_24 | "Ensure passport account is not used for assignment. Use service accounts and federated accounts where possible." |
</details>

## Examples of use in Managed Service for GitLab

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/165978612-b1ee5f96-be71-4c2b-87a6-02333a46c857.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="50" />
</a></br>

Prerequisites 
- ✅ Instance of Managed Service for GitLab (or vm with gitlab)
- ✅ Registered runner on Compute Cloud VM
- ✅ A service account assigned to the virtual machine with the necessary rights for terraform deployments

**Global pipeline stages schema**:
- checkov-test-files (block or pass)
- tfplan generate
- checkov-test-tfplan (block or pass)
- tf-apply


Examples are divided into 3 different files of pipelines:
1. **blocking mode** ".gitlab-ci(blocking_mode).yml" - blocks pipeline if checkov find security misconfiguration(check failed). 
2. **audit mode** ".gitlab-ci(audit_mode).yml" - NOT blocks pipeline if checkov find security misconfiguration(check failed) but you can see alerts. 
3. **blocking mode with specific checks in audit mode** ".gitlab-ci(blocking_mode_with_specific_checks_in_audit).yml" - blocks pipeline if checkov find security misconfiguration(check failed) but skip specific non critical Checks. 
