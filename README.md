# yc-solution-library-for-security
Yandex Cloud Solution Library for Security — это набор примеров и рекомендаций, собранных в публичном репозитории на GitHub. Они помогут компаниям, которые хотят построить безопасную инфруструктуру в Облаке и соответствовать требованиям различных регуляторов и стандартов.
Команда Yandex.Cloud проработала самые распространённые задачи, которые возникают при построении безопасности в облаке, протестировала и подробно описала необходимые сценарии.

<<!!Вставить!Здесь перекрестную ссылку на security guide текстовый>>

## Домены безопасности
- [Сетевая безопасность](#па)
  - [Пример настройки Security Groups (dev/stage/prod): Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/segmentation)
  - [Пример установки в Яндекс Облако ВМ-Межсетевой экран (NGFW): Checkpoint](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/checkpoint-1VM)
  - [Пример создания site-to-site VPN соединения с Yandex Cloud: Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/network-sec/vpn)
- [Аутентификация и управление доступом](#па)
  - [IAM модуль (с примерами использования)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auth_and_access/iam#identity-and-access-management-iam-terraform-module-for-yandexcloud)
- [Защита от вредоносного кода](#па)
  - [Развертывание Kaspersky Antivirus в Yandex.Cloud (Compute Instance, COI)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/malware-defense/kaspersy-install-in-yc)
- [Управление уязвимостями](#па)
  - [Отказоустойчивая эксплуатация PT Application Firewall на базе Yandex.Cloud](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/unmng-waf-ptaf-cluster)
  - [Установка уязвимого веб приложения (dvwa) в Яндекс Облаке (с помощью terraform) для тестирования managed WAF](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/vulnerable-web-app-waf-test)
- [Шифрование данных и управление ключами ](#па)
  - [Шифрование секретов средствами KMS при передачи их в контейнер ВМ COI Yandex.Cloud:Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/encrypt_and_keys/terraform%2BKMS%2BCOI)
- [Сбор, мониторинг и анализ аудит логов](#па)
  - [Сбор, мониторинг и анализ аудит логов в Yandex Managed Service for Elasticsearch (ELK)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK(main))
  - [Сбор, мониторинг и анализ аудит логов во внешний SIEM ArcSight](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ArcSight)
  - [Сбор, мониторинг и анализ аудит логов во внешний Splunk](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-Splunk)
  - [Use cases и важные события безопасности в аудит логах](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/_use_cases_and_searches)
- [Безопасная конфигурация](#па)
  - [Пример безопасной конфигурации Yandex Cloud Object Storage: Terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/configuration/hardering_bucket)
##
- [Безопасность Kubernetes](#)
  - Аутентификация и управление доступом Managed Kubernetes:
    - [Пример настройки ролевых моделей и политик в Managed Service for Kubernetes](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/kubernetes-security/auth_and_access/role-model-example)
  - Сбор, мониторинг и анализ аудит логов:
    - [Анализ логов безопасности k8s в ELK: аудит-логи, policy engine, falco](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK(k8s))

![Стэнд_архитектура](https://user-images.githubusercontent.com/85429798/128418857-f8062cdd-5eee-466f-85f0-931fd1c190cf.png)


