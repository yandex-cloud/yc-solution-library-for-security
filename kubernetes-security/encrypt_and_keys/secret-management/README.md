# Управление секретами c SecretManager(Lockbox)

## Необходимость класса решения Secret Manager
![image](https://user-images.githubusercontent.com/85429798/132330379-77969063-fa22-4cc7-ae94-917efb3c9a53.png)


## Secret Manager в Yandex Cloud
В облаке "из коробки"" возможно использовании 2-х вариантов Secret Manager:
- [Yandex Lockbox](https://cloud.yandex.ru/docs/lockbox/)(встроенный продукт)
- [HashiCorp Vault c поддержкой KMS](https://cloud.yandex.ru/marketplace/products/f2eokige6vtlf94uvgs2)(из marketplace)

## Описание интеграции Lockbox и k8s
Оффициальная нтеграция выполнена с помощью открытого решения External Secrets (https://github.com/external-secrets)

![image](https://user-images.githubusercontent.com/85429798/132330677-b33d54ba-8d6a-4897-b419-e46d2111c9ef.png)

![image](https://user-images.githubusercontent.com/85429798/132330706-933ff062-ce71-4263-b5f0-d6f08526ddd7.png)


#### Инструкция по настройке


[Ссылка на официальную документацию](https://cloud.yandex.ru/docs/managed-kubernetes/solutions/kubernetes-lockbox-secrets)


#### Сценарии разграничения доступов и объектов
https://external-secrets.io/guides-multi-tenancy/

## Инструкция по интеграции HashiCorp Vault с k8s
https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes


