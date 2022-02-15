# Use cases и важные события безопасности в аудит логах
В данном разделе собраны use cases и важные события безопасности платформы Yandex.Cloud.

Актуальные Use cases и важные события безопасности собраны в файле репозитория здесь [Use_Cases.pdf](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/_use_cases_and_searches/Use_Cases.pdf)

Вы можете отгружать аудит логи из сервиса [Audit Trails](https://cloud.yandex.ru/docs/audit-trails/) в [Cloud Logging](https://cloud.yandex.ru/docs/audit-trails/operations/export-cloud-logging) или в [Yandex Managed Service for Elasticsearch (ELK)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main) либо в ваш [собственный SIEM](https://cloud.yandex.ru/docs/audit-trails/concepts/export-siem)

## Синтаксис файла
Выражения по анализу событий подготовлены на языке KQL(ElsticSearch) и Cloudlogging на выбор
![image](https://user-images.githubusercontent.com/85429798/154081374-843f5c6d-a881-404a-b618-3693f1d3a11b.png)

## Пример анализа событий в Cloud Logging
![Screen Shot 2022-02-15 at 17 11 06](https://user-images.githubusercontent.com/85429798/154079879-db576283-3afb-4bc5-a1d7-4e7de9dcb987.png)

## Пример анализа событий в ELK
![image](https://user-images.githubusercontent.com/85429798/154079995-10c9d330-3e2e-4b7e-bc97-31a8b71611db.png)
