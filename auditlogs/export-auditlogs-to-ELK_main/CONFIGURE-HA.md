# Рекомендации для высокой доступности данных

Наш пример ElasticSearch устанавливается в базовой конфигурации.
В части высокой доступности данных применены следующие механизмы:
- Несколько нод для данных
- Несколько реплик для индексов
- Индексы ротируются по рекомендованной схеме, а именно:
    - По достижению индексом размера в 50ГБ, создается новый индекс, или
    - Каждый тридцать дней, создается новый индекс
- Данные отправляются в alias индекса, то есть ротация индекса не должна повлиять на работу схемы в примере

## Ротация индекса

Ротация индекса работает использует следующие сущности в ElasticSearch:
- Индексы и алиас (alias) индекса. 
- Шаблона индекса (index template).
- Политика жизненного цикла индекса (index lifecycle policy).

Первый индекс в примере создается с цифровым суффиксом - это необходимо, чтобы в результате ротации создался новый индекс с измененным суффиксом.

На созданный индекс назначается алиас, чтобы работа скрипта не зависила от суффикса в имени индекса.

![Index Alias](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-alias.jpg)

## Шаблон индекса

![Index Template](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-index-templates.jpg)

Шаблон индекса содержит все необходимые параметры для создания нового индекса в результате ротации:
- Паттерн индекса (index pattern). Новосозданные индексы, подпадающие под паттерн, будут автоматически созданы с параметрами шаблона.
- Настройки индекса. В нашем случае, это имя политики ротации (index rollover policy), количество реплик данных и rollover_alias - алиас, который будет перенесен на новый индекс.

```
{
  "index": {
    "lifecycle": {
      "name": "audit-trails-ilm",
      "rollover_alias": "audit-trails-index"
    },
    "number_of_replicas": "2"
  }
}
```

- Параметры сопоставления (mapping).

## Политика ротации

Политика ротации (index lifecycle policy) - отслеживает "жизненный путь" наших данных.
По мере устаревания данных, их можно переносить на менее производительные серверы или диски, а по прошествии определенного времени - и, вовсе, удалить.

![Index Lifecycle Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-index-policy-1.jpg)

В нашем примере настроена только горячая фаза (hot phase) и была включена рекомендованная конфигурация для rollover.

![Index Lifecycle Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-index-policy-2.jpg)

Но в продуктивном развертывавнии рекомендуется спланировать, как устаревание данных (перенос на "медленные" ноды), так и их удаление.

Удаление данных рекомендуется включить и при отсутствии других фаз, только для горячей фазы.

![Index Lifecycle Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-index-policy-3.jpg)

По прошествии определенного времени индексы с устаревшими данными будут удалены.
Если настроены снимки данных (snapshots) - то можно включить опцию удаления только при наличии снимка.
В этом случае, необходимо указать имя политики создания снимков (snapshot policy).

![Index Lifecycle Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-index-policy-4.jpg)

Настройка политики создания снимков описана ниже.

## Политика создания снимков

Снимки данных (snapshots) необходимы для создания резервных копий данных на определенный момент времени.
Рекомендуется настроить политику создания снимков в продуктивной среде.
Созданные снимки данных можно хранить в S3 хранилище Yandex.Cloud - ниже описана процедура настройки политики с использованием хранилища S3.
Снимки создаются инкрементально и не занимают много пространства в долгосрочной перспективе, так как добавляются только изменения.

Для хранения снимков в S3 хранилище необходимо:
1. Настроить сервисный аккаунт для работы с S3 и подключить его к кластеру ElasticSearch
2. Настроить права доступа
3. Подключить репозиторий к ElasticSearch

Эти шаги описаны в [документации](https://cloud.yandex.ru/docs/managed-elasticsearch/operations/s3-access) к Managed Service for ElasticSearch.

Пример созданного репозитория снимков:

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-2.jpg)

После того, как репозиторий был подключен к ElasticSearch, можно выполнить настройку первой политики для создания снимков.

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-1.jpg)

Далее, через простой мастер настройки, необходимо указать:
- Имя политики снимков
- Паттерн для имен, созданных снимков
- Репозиторий снимков, который был создан ранее
- График создания снимков (например, каждый час)
- Параметры снимков: делать снимки для всех или определенных индексов, хранить в снимке состояние кластера, и др.
- Параметры хранения снимков (retention)

Созданная политика снимков может выглядеть следующим образом:

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-4.jpg)

После создания политики, она будет видна в общем списке политик, где её можно сразу же запустить и проверить.

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-5.jpg)

В результате, создан новый снимок, который отображается в списке.

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-6.jpg)

А также, данные появились в объектном хранилище:

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-7.jpg)

Созданную политику снимков можно задействовать в политике ротации индексов, которая была создана ранее.

![Index Snapshot Policy](https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auditlogs/export-auditlogs-to-ELK_main/images/ha-snapshots-8.jpg)