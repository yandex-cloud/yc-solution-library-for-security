# Use cases and important security events in audit logs
This section contains use cases and important security events on the Yandex.Cloud platform.

Actual Use Cases and important security events are collected in the repository file here.[Use-casesANDsearches.pdf](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/_use_cases_and_searches/Use-casesANDsearches.pdf)

You can ship audit logs from the service [Audit Trails](https://cloud.yandex.ru/docs/audit-trails/) in [Cloud Logging](https://cloud.yandex.ru/docs/audit-trails/operations/export-cloud-logging) or in [Yandex Managed Service for Elasticsearch (ELK)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ELK_main) or in your [other own SIEM](https://cloud.yandex.ru/docs/audit-trails/concepts/export-siem)

## Syntax of file
Event analysis expressions are prepared in KQL (ElsticSearch) and CloudLogging to choose
![image](https://user-images.githubusercontent.com/85429798/185589916-ffe26b9b-fec4-489c-ae18-72835bfd5b91.png)

## Example Analysis of Events in Cloud Logging
![Screen Shot 2022-02-15 at 17 11 06](https://user-images.githubusercontent.com/85429798/154079879-db576283-3afb-4bc5-a1d7-4e7de9dcb987.png)

## An example of event analysis in ELK
![image](https://user-images.githubusercontent.com/85429798/154079995-10c9d330-3e2e-4b7e-bc97-31a8b71611db.png)
