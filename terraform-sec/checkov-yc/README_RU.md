# Checkov + Yandex Cloud

![image](https://user-images.githubusercontent.com/85429798/165979281-b1c59627-1386-495f-9d26-c301465a6325.png)

- [Checkov + Yandex Cloud](#checkov---yandex-cloud)
  * [Введение](#введение)
  * [Информация о проверках Yandex cloud](#информация-о-проверках-yandex-cloud)
  * [Примеры использования в Managed Service for GitLab](#примеры-использования-в-managed-service-for-gitLab)

## Введение
**Checkov теперь поддерживает объекты терраформ Yandex Cloud**.

[Checkov](https://github.com/bridgecrewio/checkov) это инструмент статического анализа кода для инфраструктуры.
Он сканирует облачную инфраструктуру, подготовленную с использованием Terraform, плана Terraform, Cloudformation, AWS SAM, Kubernetes, Helm charts, Kustomize, Dockerfile, Serverless, Bicep, OpenAPI или шаблонов ARM, и обнаруживает неверные настройки безопасности и соответствия требованиям с помощью сканирования.

Инструкции по установке и использованию доступны на [checkov page](https://github.com/bridgecrewio/checkov#getting-started)

![Screen Shot 2022-04-29 at 16 34 35](https://user-images.githubusercontent.com/85429798/165979509-a95872d4-880f-4c7f-be1a-75fedf8a721d.png)

## Информация о проверках Yandex cloud
Вы можете найти все проверки в [source code](https://github.com/bridgecrewio/checkov/tree/master/checkov/terraform/checks/resource/yandexcloud)

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

## Примеры использования в Managed Service for GitLab

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/165978612-b1ee5f96-be71-4c2b-87a6-02333a46c857.png"
         alt="Kubernetes logo" title="Kubernetes" height="50" width="50" />
</a></br>

Пререквизиты 
- ✅ Instance Managed Service for GitLab (или ВМ с gitlab)
- ✅ Зарегистрированный runner на виртуальной машине Compute Cloud
- ✅ A service account назначенный виртуальной машине с необходимыми правами для развертывания terraform

**Схема этапов конвейера**:
- checkov-test-files (block or pass)
- tfplan generate
- checkov-test-tfplan (block or pass)
- tf-apply


Примеры разбиты на 3 разных файла пайплайнов:
1. **blocking mode** ".gitlab-ci(blocking_mode).yml" - блокирует конвейер, если checkov обнаруживает неправильную конфигурацию безопасности (проверка не удалась).
2. **audit mode** ".gitlab-ci(audit_mode).yml" - НЕ блокирует конвейер, если при проверке обнаруживается неправильная конфигурация безопасности (проверка не удалась), но вы можете видеть предупреждения.
3. **blocking mode with specific checks in audit mode** ".gitlab-ci(blocking_mode_with_specific_checks_in_audit).yml" - блокирует конвейер, если проверки обнаруживают неправильную конфигурацию безопасности (проверка не удалась), но пропускают определенные некритические проверки.
