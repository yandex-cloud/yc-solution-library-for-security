// Вызов модуля

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
    any_event_dict = "yandex.cloud.audit.iam.CreateServiceAccount,event2" // оставить как есть, если не требуется, либо "yandex.cloud.audit.iam.CreateServiceAccount,event2", нащвания событий, можно получить https://cloud.yandex.ru/docs/audit-trails/concepts/events


    //TBD когда появится поддержка триггеров для cloudlogging в terraform
    //loggroup_id = "af3o0pc24hi1qmpovcss" //id лог группы, в которую AuditTrails пишет события (можно посмотреть в CloudLogging, создавалась при создании трейла)
}
