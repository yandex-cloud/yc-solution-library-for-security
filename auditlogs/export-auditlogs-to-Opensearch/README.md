# Сбор, мониторинг и анализ аудит логов Yandex.Cloud в Yandex Managed OpenSearch 

![image](https://user-images.githubusercontent.com/85429798/184665197-01f0cbca-78f3-4b32-90f1-ee6a4fa71d8e.png)

## Version

**Version-1.1**
- Changelog:
- Docker images:
    - `cr.yandex/sol/s3-opensearch-importer:1.1`

## Описание решения
Решение позволяет собирать, мониторить и анализировать аудит логи Yandex.Cloud (Audit Trails) в OpenSearch  из следующих источников:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)

> Решение является постоянно обновляемым и поддерживаемым Security-командой Yandex.Cloud.

> Важно! По умолчанию данная конструкция предлагает удалять файлы после вычитывания из бакета, но вы можете одновременно хранить аудит логи Audit Trails в S3 на долгосрочной основе и отсылать в Elastic. Для этого необходимо создать два Audit Trails в разных S3 бакетах:. Первый бакет будет использоваться только для хранения. Второй бакет будет использоваться для интеграции с OpenSearch 

## Что делает решение
- ☑️ Отправляет данные в существующий Yandex Managed OpenSearch  кластер (если у вас нет кластера OpenSearch  то воспользуйтесь инструкцией ниже)
- ☑️ Разворачивает COI Instance с контейнером на базе образа s3-elk-importer (`cr.yandex/sol/s3-opensearch-importer:latest`)
- ☑️ Загружает Security Content в OpenSearch  (Dashboards, Detection Rules (с alerts), etc.)
- ☑️ Обеспечивает непрерывную доставку json файлов с аудит логами из Yandex Object Storage (Audit Trails) в OpenSearch 
- ☑️ Создает индексы в двух репликах, настраивает базовую политику rollover (создания новых индексов каждые тридцать дней или по достижению 50ГБ), для дальнейшей настройки в части высокой доступности данных и для настройки снимков данных в S3 - см. [рекомендации](./CONFIGURE-HA.md). 

## Схема решения
<img width="786" alt="image" src="https://user-images.githubusercontent.com/85429798/184668940-295e5e53-615d-434a-8e03-7396d00e0781.png">


## Security Content
**Security Content** — объекты OpenSearch , которые автоматически загружаются решением. Весь контент разработан с учетом опыта Security команды Yandex.Cloud и на основе опыта Клиентов облака.

Содержит следующий Security Content:
- Dashboard, на котором отражены все use cases и полезная статистика
- Набор Saved Queries для удобного поиска Security событий
- Пример Alert на которые настроены оповещения (Клиенту самостоятельно необходимо указать назначение уведомлений)
- Все интересные поля событий преобразованы в формат [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/index.html), полная табличка маппинга в файле [Описание объектов](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/Описание%20объектов.pdf)

Подробное описание в файле [ECS-mapping.docx](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ELK_main/papers/ECS-mapping_new.pdf)

## Процесс обновления контента
Скоро..к следующей версии

## Установка отказоустойчивого OpenSearch  Yandex Managed Service for OpenSearch 
https://cloud.yandex.ru/docs/managed-opensearch/quickstart

## Установка решения с помощью Terraform

Для установки с помощью terraform перейдите в раздел [terraform](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/add-opensearch-solution/auditlogs/export-auditlogs-to-Opensearch/terraform)

По результатам выполнения tf скрипта и ручных действий указанных ниже, в указанный вами OpenSearch  будут загружаться события audit trails из облака и будет загружен security content (dashboard, filters, mapping etc.) для работы с ними

По итогу установки у вас будет создан tenant "at-tenant", в котором находятся все объекты

## Настройка Alerts и Destination
Алертинг и правила реагирования в OpenSearch  выполняется с помощью механизма [Alerting](https://opensearch.org/docs/latest/monitoring-plugins/alerting/index/)

Наше решение уже загружает пример monitor, вы можете взять его как пример для старта и сделать алерты по аналогии. Перейдите во вкладку Alerting - Monitors и найдите там "test". Нажмите кнопку edit, промотайте вниз и раскройте вкладку triggers и в ней укажите action. Выберите там заранее созданный канал [нотификации](https://opensearch.org/docs/latest/notifications-plugin/index/) (например slack) 



## Самостоятельная Установка all-in-one Openasearch на ВМ
Для устновки opensearch можно воспользоваться оффициальной документацией. Например [установка с помощью docker](https://opensearch.org/docs/2.1/opensearch/install/index/)

Для настройки TLS в opensearch dashboard используйте [инструкцию](https://opensearch.org/docs/2.1/dashboards/install/tls/)

Для генерации самоподпсанного SSL сертификата используйте [инстуркцию](https://opensearch.org/docs/2.1/security-plugin/configuration/generate-certificates/)
Либо загружите ваш собственный сертификат

Здесь представлены тестовые примеры файлов для установки opensearch в разделе [deploy-of-opensearch](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/add-opensearch-solution/auditlogs/export-auditlogs-to-Opensearch/deploy-of-opensearch)

p.s: не забудьте предоставить необходимые права доступа на файлы с сертификатом и ключем

## Рекомендации по настройке retention, rollover и snapshots:

[Рекомендации по настройке retention, rollover и snapshots](./CONFIGURE-HA.md)
