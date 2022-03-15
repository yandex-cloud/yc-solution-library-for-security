# Secret Management with Secret Manager (Lockbox)

## Need in Secret Manager solutions
![image](https://user-images.githubusercontent.com/85429798/132330379-77969063-fa22-4cc7-ae94-917efb3c9a53.png)


## Secret Manager in Yandex.Cloud
Yandex.Cloud supports two Secret Managers out-of-the-box:
- [Yandex Lockbox](https://cloud.yandex.ru/docs/lockbox/) (embedded product).
- [HashiCorp Vault with KMS support](https://cloud.yandex.ru/marketplace/products/f2eokige6vtlf94uvgs2) (from the marketplace).

## Description of Lockbox-to-K8s integration
The official integration is carried out using the open-source External Secrets solution (https://github.com/external-secrets).

![image](https://user-images.githubusercontent.com/85429798/132330677-b33d54ba-8d6a-4897-b419-e46d2111c9ef.png)

![image](https://user-images.githubusercontent.com/85429798/132330706-933ff062-ce71-4263-b5f0-d6f08526ddd7.png)


#### Setup instructions


[Link to the official documentation](https://cloud.yandex.ru/docs/managed-kubernetes/solutions/kubernetes-lockbox-secrets)


#### Use cases for access and object differentiation
https://external-secrets.io/guides-multi-tenancy/

## Instructions for integrating HashiCorp Vault with K8s
https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes
