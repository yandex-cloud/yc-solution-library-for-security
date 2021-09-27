## Мониторинг Audit Trails и событий в Yandex Cloud Monitoring

![image](https://user-images.githubusercontent.com/85429798/134897482-37c00391-7a01-48c1-9b78-bae7513b42d0.png)

![image](https://user-images.githubusercontent.com/85429798/134897506-79fbbffa-0537-4028-b1f3-132486127fdf.png)

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

![image](https://user-images.githubusercontent.com/85429798/134897575-762c94fc-e709-4aed-a143-ec512852b5da.png)

#### Мониторинг самого сервиса Audit Trails
- Перейдите в Audit Trails -> Monitoring -> Открыть в мониторинге -> Обзор метрик
- Сформируйте необходимый запрос к желаемой метрике из списка ниже, например: "service="audit-trails", event_type="yandex.cloud.audit.compute.AddInstanceOneToOneNat"
- Нажмите на "..." троеточие -> "Создать алерт"
- Настройте [алерт согласно документации](https://cloud.yandex.ru/docs/monitoring/operations/alert/create-alert) на интересующий вас порог, например "Больше 0"

![image](https://user-images.githubusercontent.com/85429798/134897649-90cedcfc-ba5f-4037-9278-a5fd58beb12d.png)


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

