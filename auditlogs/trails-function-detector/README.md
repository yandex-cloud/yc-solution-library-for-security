## Yandex Cloud: Trails-function-detector
Оповещения и реагирование на события ИБ Audit trails с помощью Cloud Logging/Cloud Functions + Telegram

![Logo-scheme](https://user-images.githubusercontent.com/85429798/132173603-0fde1851-2572-404a-82a0-33034e16d0ea.png)

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/132173624-89b9fc81-aea0-43ac-a30b-fc354ab3659c.png"
         alt="Kubernetes logo" title="Kubernetes" height="500" width="420" />
</a></br>

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/132173630-c34a6bd9-7e39-472e-8199-6a334fa0753d.png"
         alt="Kubernetes logo" title="Kubernetes" height="500" width="420" />
</a></br>



#### Блокеры
- AuditTrails в UI: вывод логов в CloudLogging
- Function_trigger на CloudLogging в UI

#### Будет доработано
- Function_trigger на CloudLogging в terraform 
- AuditTrails в terraform

#### Описание 
Решение выполняет c помощью CloudFunctions и AuditTrails:

- Оповщение в telegram на следующие события AuditTrails (опционально):
    - 1)"Create danger, ingress ACL in SG (0.0.0.0/0)"
    - 2)"Change Bucket access to public"
    - 3)"Assign rights to the secret (Lockbox) to some account"
- (Опционально) Активное реагирование:
    - Удаление опасного правила группы безопасности (для правила № 1)
    - Удаление назначенных прав на секрет в Lockbox (для правила № 3)
- Оповещение в telegram на любое событие AuditTrails (на выбор)

#### Общая схема 

![Tech_scheme](https://user-images.githubusercontent.com/85429798/132173681-8c32b75f-ebf5-4c98-ba5f-bc90ea482d07.png)

#### Пререквизиты
- :white_check_mark: Созданная custom лог группа в CloudLogging ([инструкция](https://cloud.yandex.ru/docs/logging/operations/create-group))
- :white_check_mark: Включенный сервис Audit Trails (с выводом логов в лог группу CloudLogging) ([инструкция](https://cloud.yandex.ru/docs/audit-trails/quickstart))
- :white_check_mark: Сервисный аккаунт
- :white_check_mark: Созданный бот в telegram ([инструкция](https://tlgrm.ru/docs/bots#kak-sozdat-bota))
- :white_check_mark: ID чата с telegram ботом (для получения chat-id сначала пишем хотябы одно сообщение боту, далее используем https://api.telegram.org/bot<token>/getUpdates для получения id чата)
- :white_check_mark: После выполнения Terraform скрипта, необходимо в UI включить trigger на CloudLogging (подробности ниже)


#### Описание terraform 
Модуль terraform:
- Принимает на вход: 

```Python
module "trails-function-detector" {
    source = "../" // путь до модуля
    //Общие:
    folder_id = "aoem46r1onav1soovie4" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id
    service_account_id = "bfbgln3qf8f71r1jbvjb" // service-account, которому будут назначены права: serverless.functions.invoker
    
    //Инфо для telegram уведомлений:
    bot_token = "1987471230:AAH4mpdc4OUFlpml2oy830PrpO6Y_5SnvVo" // токен telegram бота для отправки уведомлений (Для того, чтобы получить токен https://proglib.io/p/telegram-bot)
    chat_id_var = "62689455" // для получения chat-id сначала пишем хоть одно сообщение боту, далее используем https://api.telegram.org/bot<token>/getUpdates для получения
    //Включение Detection-rules:
    rule_sg_on = "True" // Правило: "Create danger, ingress ACL in SG (0.0.0.0/0)" (если не требуется то выставить в False)
    del_rule_on = "False" // Включение активного реагирования на правило rule_sg_on: удаляет опасное правило группы безопасности

    rule_bucket_on = "True" // Правило: "Change Bucket access to public" (если не требуется то выставить в False)

    rule_secret_on = "True" // Правило: "Assign rights to the secret (Lockbox) to some account" (если не требуется то выставить в False)
    del_perm_secret_on = "False" // Включение активного реагирования на правило rule_secret_on: удаляет назначенные права на секрет в Lockbox
    
    //Доп. события для получения уведомлений без деталей
    any_event_dict = "yandex.cloud.audit.iam.CreateServiceAccount,event2" // оставить как есть, если не требуется, либо "yandex.cloud.audit.iam.CreateServiceAccount,event2", названия событий, можно получить https://cloud.yandex.ru/docs/audit-trails/concepts/events


    //TBD когда появится поддержка триггеров для cloudlogging в terraform
    //loggroup_id = "af3o0pc24hi1qmpovcss" //id лог группы, в которую AuditTrails пишет события (можно посмотреть в CloudLogging, создавалась при создании трейла)
}
```

- Выполняет: 
	- назначение прав serverless.functions.invoker на указанный сервисный аккаунт (в случае включения реагирования, назначает также права editor)
    - создает функцию на основе python скрипта (функция выполняет описанную выше логику)

- Действия после terraform (будет упаковано в terraform позже):
    - необходимо через UI включить Function_trigger на CloudLogging со следующими параметрами:
        - тип: CloudLogging
        - лог группа: созданная в CloudLogging
        - время ожидания: 10
        - размер группы сообщений: 5
        - функция: созданная с помощью terraform скрипта функция "function-for-trails"


#### Пример вызова модуля:
См. Пример вызова модулей в /example/main.tf 

