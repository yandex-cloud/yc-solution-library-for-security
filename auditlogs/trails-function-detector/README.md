## Yandex.Cloud Trails-function-detector: Alerts and response to Information Security events in Audit Trails using Cloud Logging and Cloud Functions + Telegram

![Logo-scheme](https://user-images.githubusercontent.com/85429798/132173603-0fde1851-2572-404a-82a0-33034e16d0ea.png)

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/132173624-89b9fc81-aea0-43ac-a30b-fc354ab3659c.png"
         alt="Kubernetes logo" title="Kubernetes" height="500" width="460" />
</a></br>

<a href="https://kubernetes.io/">
    <img src="https://user-images.githubusercontent.com/85429798/132173630-c34a6bd9-7e39-472e-8199-6a334fa0753d.png"
         alt="Kubernetes logo" title="Kubernetes" height="500" width="460" />
</a></br>


#### To be revised
- Function_trigger on Cloud Logging in Terraform 
- Audit Trails in Terraform

#### Description 
The solution uses Cloud Functions and Audit Trails to perform:

- Telegram alerts for the following Audit Trails events (optional):
    - Create danger, ingress ACL in SG (0.0.0.0/0).
    - Change Bucket access to public.
    - Assign rights to the secret (Lockbox) to some account.
    - To be updated on request based on the [list of current use cases](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/_use_cases_and_searches).
- Active response (optional):
    - Removing a dangerous security group rule: for Rule No. 1.
    - Removing assigned rights for a secret in Lockbox: for Rule #3.
- Telegram alerting for any selected Audit Trails event.

#### Generic diagram 

![image](https://user-images.githubusercontent.com/85429798/134821478-46e3e6a4-4bf9-4425-8d8d-61bc87bc1bb2.png)

#### Prerequisites:
- :white_check_mark: A custom log group created  in Cloud Logging ([instructions](https://cloud.yandex.ru/docs/logging/operations/create-group)).
- :white_check_mark: Audit Trails service enabled with logs output to the Cloud Logging log group ([instructions](https://cloud.yandex.ru/docs/audit-trails/quickstart)).
- :white_check_mark: Service account (it will be granted relevant rights).
- :white_check_mark: A bot created in Telegram ([instructions](https://tlgrm.ru/docs/bots#kak-sozdat-bota)).
- :white_check_mark: ID of the chat with a Telegram bot (to get the Chat ID, first write at least one message to the bot, then use https://api.telegram.org/bot<token>/getUpdates to get the Chat ID).
- :white_check_mark: After you run the Terraform script, enable the trigger for Cloud Logging in the UI (see details below).


#### Terraform description 
Terraform module:
- It accepts the following input: 

```Python
// Call the module
module "trails-function-detector" {
    source = "../" // path to the module
    //General:
    folder_id = "XXXXXXX" // your_folder_id
    service_account_id = "XXXXXXX" // Your service account ID to which the serverless.functions.invoker rights  will be assigned
    
    //Info for Telegram alerts:
    bot_token = " XXXXXX:XXXXXXXXXXXXXX" // A token of a Telegram bot for sending alerts. To get a token: https://proglib.io/p/telegram-bot
    chat_id_var = "XXXXXXX" // To get the Chat ID, first write any message to the bot, then use https://api.telegram.org/bot<token>/getUpdates.
    //Enable Detection-rules:
    rule_sg_on = "True" // The rule: "Create danger, ingress ACL in SG (0.0.0.0/0)" (set to False if not needed)
    del_rule_on = "False" // Enable active response to the rule_sg_on rule: removes the danger rule from a security group

    rule_bucket_on = "True" // The rule: "Change Bucket access to public" (set to False if not needed)

    rule_secret_on = "True" // The rule: "Assign rights to the secret (Lockbox) to some account" (set to False if not needed)
    del_perm_secret_on = "False" // Enable active response to the rule rule_secret_on rule: remove rights for the secret assigned in Lockbox
    
    //Additional events for alerts without details
    any_event_dict = "yandex.cloud.audit.iam.CreateServiceAccount,event2" // Leave as is unless you need an alert for additional events, or "yandex.cloud.audit.iam.CreateServiceAccount,event2". To get event names, go to: https://cloud.yandex.ru/docs/audit-trails/concepts/events


    //TBD when we support triggers for Cloud Logging in Terraform
    //loggroup_id = "af3o0pc24hi1qmpovcss" //The ID of the log group to which Audit Trails writes events (you can view it in Cloud Logging, it was created along with the trail)
}

```

- Assigns serverless rights.functions.invoker for the specified service account (if the response is enabled, it also assigns the rights vpc.SecurityGroups.admin, lockbox.admin).
- Creates a function based on a Python script (the function executes the logic described above).

- After Terraform (it will be packed in Terraform later), enable Function_trigger on Cloud Logging via the UI using the following parameters:
        Type: `Cloud Logging`
        Log group: The one created in Cloud Logging
        Waiting time: `10`
        Batch size: `5`
        Function: The function-for-trails function that you created by a Terraform script


#### Example of calling a module:
See the example of calling modules in /example/main.tf 
