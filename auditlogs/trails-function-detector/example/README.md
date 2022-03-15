
1) Download the files and go to the example folder.
2) Fill out the main.tf file with your values.
3) Run:
```
terraform init
```

```
terraform apply
```


```Python
// Call the module

module "trails-function-detector" {
    source = "../" // path to the module
    //General:
    folder_id = "XXXXXXX" // your_folder_id
    service_account_id = "XXXXXXX" // your service-account ID to which the serverless.functions.invoker rights  will be assigned
    
    //Info for Telegram alerts:
    bot_token = "XXXXXX:XXXXXXXXXXXX" // A token of a Telegram bot for sending alerts (to get a token, go to: https://proglib.io/p/telegram-bot)
    chat_id_var = "XXXXXXX" // To get the Chat ID, first write at least one message to the bot, then use https://api.telegram.org/bot<token>/getUpdates
    //Enable Detection-rules:
    rule_sg_on = "True" // The rule "Create danger, ingress ACL in SG (0.0.0.0/0)" (set to False if not needed)
    del_rule_on = "False" // Enable active response to the rule_sg_on rule: removes the danger rule from a security group

    rule_bucket_on = "True" // The rule "Change Bucket access to public" (set to False if not needed)

    rule_secret_on = "True" // The rule "Assign rights to the secret (Lockbox) to some account" (set to False if not needed)
    del_perm_secret_on = "False" // Enable active response to the rule rule_secret_on rule: remove rights for the secret assigned in Lockbox
    
    //Additional events for alerts without details
    any_event_dict = "yandex.cloud.audit.iam.CreateServiceAccount,event2" // Leave as is unless you need an alert for additional events, or "yandex.cloud.audit.iam.CreateServiceAccount,event2" (to get event names, go to: https://cloud.yandex.ru/docs/audit-trails/concepts/events)


    //TBD when we support triggers for Cloud Logging in Terraform
    //loggroup_id = "af3o0pc24hi1qmpovcss" //The ID of the log group to which Audit Trails writes events (you can view it in Cloud Logging, it was created when creating the trail)
}

```
