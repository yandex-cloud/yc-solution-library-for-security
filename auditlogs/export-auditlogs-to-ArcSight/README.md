# Сбор, мониторинг и анализ аудит логов во внешний SIEM ArcSight
![dash](https://user-images.githubusercontent.com/85429798/128209194-bc4eb274-1b97-4271-a712-e00a5f3f9b84.png)
![use_cases](https://user-images.githubusercontent.com/85429798/128209212-a705f950-4eea-4305-8f21-decfc2ab7af0.png)




## Описание решения
Актуальная версия Security Content находится в репозитории коллег(указать откуда) - https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex
Решение позволяет собирать, мониторить и анализировать аудит логи в Yandex.Cloud со следующих источников:
- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)

## Часть про услуги , поддержку и тд
Описание услуг и про компанию

## 2 сценария отгрузки логов
- [x] Загрузка лог файлов в ArcSight с сервера, который находится внутри инфраструктуры удаленной площадки Заказчика

- [x] Загрузка лог файлов в ArcSight с помощью ВМ, которая находится в Yandex Cloud 


## Схема решения
#### Сценарий № 1 Загрузка лог файлов в ArcSight с сервера, который находится внутри инфраструктуры удаленной площадки Заказчика
![Сценарий1](https://user-images.githubusercontent.com/85429798/128193658-da11bd41-95d8-4aa6-95cc-2ead40bbfec3.png)

#### Сценарий № 1 Загрузка лог файлов в ArcSight с сервера, который находится внутри инфраструктуры удаленной площадки Заказчика



## Security Content
Security Content - объекты ArcSight, которые загружаются по инструкции. Весь контент разработан совместно с командой ArcSight Pro (!вставить ссылку) с учетом многолетнего опыта Security команды Yandex.Cloud и на основе опыта Клиентов облака.

Актуальная версия Security Content находится в репозитории коллег(указать откуда) - https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex

Содержит следующий Security Content:
- Parsing file (+ map file)
- Dashboard, на котором отражена полезная статистика
- Набор Filters, Active channels, Active lists
- Набор Правил корреляции (Rules). [Подробное описание списка правил корреляции](https://github.com/yandex-cloud/yc-solution-library-for-security/blob/master/auditlogs/export-auditlogs-to-ArcSight/Use-cases.docx) (Клиенту самостоятельно необходимо указать назначение уведомлений)
- Все интересные поля событий преобразованы в формат [Common Event Format](https://community.microfocus.com/cyberres/productdocs/w/connector-documentation/38809/arcsight-common-event-format-cef-implementation-standard)

Подробное описание мапинга полей в файле [Поля ArcSight_JSON.docx](https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex/blob/master/Поля%20ArcSight_JSON.docx)

## Долгосрочное хранение логов в S3
По умолчанию данная инструция предлагает удалять файлы после вычитывания, но вы можете одновременно хранить аудит логи AuditTrails в S3 на долгосрочной основе и отсылать в ArcSight.
Для этого необходимо создать 2 AuditTrails в разные S3 buckets:
- 1 Bucket использовать только для хранения 
- 2 Bucket использовать для интеграции с ArcSight 

## Инструкция по 2 сценариям
#### Пререквизиты для обоих сценариев:
- :white_check_mark: Object Storage Bucket для AuditTrails ([инструкция](https://cloud.yandex.ru/docs/storage/quickstart))
- :white_check_mark: Включенный сервис AuditTrail в UI ([инструкция](https://cloud.yandex.ru/docs/audit-trails/quickstart))

#### Сценарий № 1 "Загрузка лог файлов в  ArcSight с сервера, который находится внутри инфраструктуры удаленной площадки Заказчика"
1) Установите на сервер внутри инфраструктуры удаленной площадки и подготовьте к работе утилиту s3fs [согласно инструкции](https://cloud.yandex.ru/docs/storage/tools/s3fs) . Результат: смонтированный в качестве папки Object Storage Bucket, в котором находятся json файлы AuditTrails. Например: "/var/trails/"

2) Установите на ваш сервер ПО ArcSight SmartConnector (FlexAgent - JSON Folder follower) [согласно оффициальной инструкции](https://www.microfocus.com/documentation/arcsight/arcsight-smartconnectors/AS_smartconn_install/)

3) При установке выбирете "ArcSight FlexConnector JSON Folder Follower" и укажите примонтированную папку ранее "/var/trails/"

4) Укажите JSON configuration filename prefix - "yc"

5) Завершите установку connector 

6) Скачайте все файлы Security Content из репозитория - https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex

7) Скопируйте файл "yc.jsonparser.properties" в <папку установки агента>/current/user/agent/flexagent

8) Скопируйте файл "map.0.properties" в <папку установки агента>/current/user/agent/map

9) отредактируйте файл vi <папку установки агента>/current/user/agent/agent.properties следующим образом:
- agents[0].mode=DeleteFile 
- agents[0].proccessfoldersrecursively=true 

10) Запустите коннектор и убедитесь, что событий поступают
![end](https://user-images.githubusercontent.com/85429798/128209247-c1582fc9-ea2a-4908-9c95-618ac1a097ee.png)




#### Сценарий № 2 "Загрузка лог файлов в  ArcSight с помощью ВМ, которая находится в Yandex Cloud "

ручное 
пререквизиты, что должен быть впн или интерконнект


через терраформ пример с установкой VPN соединения










