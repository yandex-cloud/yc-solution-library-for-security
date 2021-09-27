## Мониторинг Audit Trails и событий в Yandex Cloud Monitoring

скрин общих дешбордов трейлза

скрин конкретно по сек группе например из презвы

### Описание 
Решение содержит рекомендации о том, как мониторить работоспособность самого сервиса Audit Trails и событий безопасности с помощью сервиса [Yandex Monitoring](https://cloud.yandex.ru/services/monitoring)

- Мониторинг самого сервиса Audit Trails:
    - статус объета Trail (Active или не Active)
    - кол-во обработанных событий (наличие всплесков)
- Мониторинг событий безопасности:
    - список представлен ниже

#### Мониторинг самого сервиса Audit Trails
- Перейдите в Audit Trails -> Monitoring -> Открыть в мониторинге
- Выберите необходимый dashboard: "Trails by status" или "Delivered events"
- Нажмите на "..."(троеточие) , выберите "создать алерт"
- Настройте [алерт согласно документации](https://cloud.yandex.ru/docs/monitoring/operations/alert/create-alert) на интересующий вас порог,например на dashboard "Trails by status" условие "status не равен 1 в течении 5 минут" (раз в секунду trail шлет метрику 1, если жив)

вставить скрин

#### Мониторинг самого сервиса Audit Trails
- Перейдите в Audit Trails -> Monitoring -> Открыть в мониторинге -> Обзор метрик
- Сформируйте необходимый запрос к желаемой метрике из списка ниже, например: "service="audit-trails", event_type="yandex.cloud.audit.compute.AddInstanceOneToOneNat"
- Нажмите на "..." троеточие -> "Создать алерт"
- Настройте [алерт согласно документации](https://cloud.yandex.ru/docs/monitoring/operations/alert/create-alert) на интересующий вас порог, например "Больше 0"

#### Список интересных метрик с точки зрения ИБ
- UpdateSecurityGroup (Изменение группы безопасности)
- UpdateSecretAccessBindings (Назначение прав на lockbox секрет)
- AddInstanceOneToOneNat (Добавление публичного IP-адреса виртуальной машине)
- RemoveInstanceOneToOneNat (Удаление публичного IP-адреса ВМ.)
- DeleteInstance (удаление ВМ)
- instancegroup.DeleteInstanceGroup (удаление группы ВМ)
- CreateAccessKey (Создание ключа доступа)
- CreateApiKey (Создание API ключа)
- DeleteFederation (удаление федерации)
- UpdateServiceAccountAccessBindings (Обновление списка привязок прав доступа)
- DeleteSymmetricKeyy (Удаление симметричного ключа.)
- ScheduleSymmetricKeyVersionDestruction (Запланирование уничтожения версии симметричного ключа.)
- DeleteCloud (Удаление облака)
- DeleteFolder (Удаление папки)
- BucketAclUpdate (Изменение ACL бакета.)
- BucketDelete (Удаление бакета.)
- BucketPolicyUpdate (Изменение политик доступа бакета.)
- CreateNetwork (Создание облачной сети.)
- DeleteNetwork (Удаление облачной сети.)
- др.

вставить скрин
