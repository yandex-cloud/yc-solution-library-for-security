# Управление секретами c SecretManager(Lockbox)

## Необходимость класса решения Secret Manager
Картинка необх!!!

## Secret Manager в Yandex Cloud
В облаке "из коробки"" возможно использовании 2-х вариантов Secret Manager:
- [Yandex Lockbox](https://cloud.yandex.ru/docs/lockbox/)(встроенный продукт)
- [HashiCorp Vault c поддержкой KMS](https://cloud.yandex.ru/marketplace/products/f2eokige6vtlf94uvgs2)(из marketplace)

## Описание интеграции Lockbox и k8s
Оффициальная нтеграция выполнена с помощью открытого решения External Secrets (https://github.com/external-secrets)

Картинка из Ext secrets!!!!

Картинка схемы (пока упрощенка)

TBD детальная схема

[Ссылка на официальную документацию](https://external-secrets.io/provider-yandex-lockbox/)

TBD ссылка на документацию Yandex Cloud

## Сценарии разграничения доступов и объектов
https://external-secrets.io/guides-multi-tenancy/



## Сложности использования HashiCorp Vault
Картинка сложностей с hashicorp


