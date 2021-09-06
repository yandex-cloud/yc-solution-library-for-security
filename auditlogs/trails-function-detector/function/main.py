import json
import os
import sys
import uuid
import string
import random
from datetime import datetime
import requests

# -------------------------Env
full_log = []
# Для того, чтобы получить токен https://proglib.io/p/telegram-bot
bot_token = os.environ['BOT_TOKEN']
# Для получения chat-id сначала пишем хоть одно сообление боту, далее используем https://api.telegram.org/bot<token>/getUpdates
chat_id_var = os.environ['CHAT_ID']
# набор типов событий, на которые алертить, без деталей
temp_any_event_dict = os.environ['EVENT_DICT']

# Включение detection rules with details
rule_sg_on = os.environ['RULE_SG_ON']
rule_bucket_on = os.environ['RULE_BUCKET_ON']
rule_secret_on = os.environ['RULE_SECRET_ON']


# Active Remediations
del_rule_on = ['DEL_RUL_ON']
del_perm_secret_on = ['DEL_PERM_SECRET_ON']

#--------------Преобразование any_event_dict
any_event_dict = temp_any_event_dict.split(",")

# -------------------------
def handler(event, context):
    # Общая функция, которую вызывает триггер вызова функции
    # Тригер  преобразовывает исходный json передаваемый в event в dict c помощью метода json.loads.
    # https://cloud.yandex.ru/docs/functions/concepts/trigger/cloudlogs-trigger
    # https://cloud.yandex.ru/docs/functions/lang/python/handler

    # Вызов функции для парсинга
    main_parse(event)


def main_parse(event):
    # Пробегаемся по сообщению и формируем dict с json событий trails
    for item in event['messages']:
        for log_entry in item['details']['messages']:
            full_log.append(log_entry['json_payload'])

    # вызов функций правиил:
    rule_any_event(full_log)  # включено всегда

    # Включаем эти правила в зависимости от переменных
    if (rule_sg_on):
        rule_sg(full_log)

    if (rule_bucket_on):
        rule_bucket(full_log)

    if (rule_secret_on):
        rule_secret(full_log)


def prepare_for_alert(json_dict):
    # Функция, которая готовит словарь с данными из ивента для алерта
    prep_dict = {}
    prep_dict['🕘 timestamp'] = json_dict['event_time']
    prep_dict['👨 subject_name'] = json_dict['authentication']['subject_name']
    prep_dict['☁️ cloud_name'] = json_dict['resource_metadata']['path'][0]['resource_name']
    prep_dict['🗂 folder_name'] = json_dict['resource_metadata']['path'][1]['resource_name']
    prep_dict['subject_id'] = json_dict['authentication']['subject_id']
    prep_dict['subject_type'] = json_dict['authentication']['subject_type']
    prep_dict['folder_id'] = json_dict['resource_metadata']['path'][1]['resource_id']
    return prep_dict

# -----------------Detection rules
def rule_sg(g):
    #Правило: "Create danger, ingress ACL in SG (0.0.0.0/0)"
    TUMBLR = False  # Переключатель срабатывания правила
    for json_dict in g:
        if (json_dict['event_type'] in ["yandex.cloud.audit.network.UpdateSecurityGroup", "yandex.cloud.audit.network.CreateSecurityGroup"]
                and json_dict['event_status'] != "STARTED"):
            # print(json_dict['event_type'])
            for item2 in json_dict['details']['rules']:
                # print(item2['direction'])
                if (item2['direction'] == "INGRESS" and "cidr_blocks" in item2 and item2['cidr_blocks']['v4_cidr_blocks'] == ['0.0.0.0/0']):
                    # print(item2['cidr_blocks']['v4_cidr_blocks'])
                    TUMBLR = True
            # Кастомные поля для вывода в алерт
            custom_dict = {}

            # для добавления в url
            folder_id = json_dict['resource_metadata']['path'][1]['resource_id']
            # для добавления в url
            security_group_id = json_dict['details']['security_group_id']
            custom_dict[
                '🔗 url_to_sec_group'] = f"https://console-preprod.cloud.yandex.ru/folders/{folder_id}/vpc/security-groups/{security_group_id}/overview"
            custom_dict['🕸 network_name'] = json_dict['details']['network_name']
            custom_dict['security_group_id'] = json_dict['details']['security_group_id']
            security_rule_id = json_dict['details']['rules'][0]['id']
            custom_dict['security_group_name'] = json_dict['details']['security_group_name']
            custom_dict['security_rule_id'] = json_dict['details']['rules'][0]['id']
            custom_dict['ports'] = json_dict['details']['rules'][0]['ports']['to_port']

            # Вызов функции подготовки базовых полей
            result_prep_f = prepare_for_alert(json_dict)
            # Вызов реагирования
            if (TUMBLR == True and del_rule_on == True):
                del_rule(security_group_id, security_rule_id)
                custom_dict['Выполнено реагирование'] = "Опасное правило удалено"
            # Объединение базовых полей и кастомных
            sum_of_dict = {**result_prep_f, **custom_dict}

    # Вызов отправки в телеграм, если есть сработка
    event_type = json_dict['event_type']
    if (TUMBLR):
        send_message(sum_of_dict, event_type)


# ----

def rule_bucket(g):
    #Правило: "Change Bucket access to public"
    TUMBLR = False  # Переключатель срабатывания правила
    for json_dict in g:
        if (json_dict['event_type'] == "yandex.cloud.audit.storage.BucketUpdate" and json_dict['event_status'] != "STARTED"):
            if ("true" in [json_dict['details']['list_access'], json_dict['details']['objects_access'], json_dict['details']['settings_read_access']]):
                TUMBLR = True
            # Кастомные поля для вывода в алерт
            custom_dict = {}

            custom_dict['🧺 bucket_name'] = json_dict['details']['bucket_id']
            bucket_id = json_dict['details']['bucket_id']
            # для добавления в url
            folder_id = json_dict['resource_metadata']['path'][1]['resource_id']
            custom_dict[
                '🔗 bucket_url'] = f"https://console-preprod.cloud.yandex.ru/folders/{folder_id}/storage/bucket/{bucket_id}?section=settings"

            # Вызов функции подготовки базовых полей
            result_prep_f = prepare_for_alert(json_dict)

            # Объединение базовых полей и кастомных
            sum_of_dict = {**result_prep_f, **custom_dict}

    # Вызов отправки в телеграм, если есть сработка
    event_type = json_dict['event_type']
    if (TUMBLR):
        send_message(sum_of_dict, event_type)

# -------
def rule_secret(g):
    #Правило: "Assign rights to the secret (LockBox) to some account"
    TUMBLR = False  # Переключатель срабатывания правила
    for json_dict in g:
        if (json_dict['event_type'] in ["yandex.cloud.audit.lockbox.UpdateSecretAccessBindings"] and json_dict['event_status'] != "STARTED"):
            for item2 in json_dict['details']['access_binding_deltas']:
                if (item2['action'] == "ADD"):
                    TUMBLR = True
            # Кастомные поля для вывода в алерт
            custom_dict = {}

            # для добавления в url
            folder_id = json_dict['resource_metadata']['path'][1]['resource_id']
            # для добавления в url
            secret_id = json_dict['details']['secret_id']
            custom_dict['assigned_role'] = json_dict['details']['access_binding_deltas'][0]['access_binding']['role_id']
            role_id = json_dict['details']['access_binding_deltas'][0]['access_binding']['role_id']
            sa_id = json_dict['details']['access_binding_deltas'][0]['access_binding']['subject_id']
            custom_dict['assigned_subject'] = json_dict['details']['access_binding_deltas'][0]['access_binding']['subject_name']
            custom_dict['assigned_subject_type'] = "*" + \
            json_dict['details']['access_binding_deltas'][0]['access_binding']['subject_type'] + "*"
            custom_dict['🔐 secret_name'] = json_dict['details']['secret_name']
            custom_dict['🔗 url_to_secret'] = f"https://console-preprod.cloud.yandex.ru/folders/{folder_id}/lockbox/secret/{secret_id}/overview"

            # Вызов функции подготовки базовых полей
            result_prep_f = prepare_for_alert(json_dict)

            # Вызов реагирования
            if (TUMBLR == True and del_perm_secret_on == True):
                del_perm_secret(secret_id, role_id, sa_id)
                custom_dict['Выполнено реагирование'] = "Назначенные права удалены"

            # Объединение базовых полей и кастомных
            sum_of_dict = {**result_prep_f, **custom_dict}

    # Вызов отправки в телеграм, если есть сработка
    event_type = json_dict['event_type']
    if (TUMBLR):
        send_message(sum_of_dict, event_type)


# --------------------any-event-funct
#Функция для легкого срабатывания по указанным событиям (не выводит деталей, не содержит реагирования)
def rule_any_event(g):
    #Правило: "Change Bucket access to public"
    TUMBLR = False  # Переключатель срабатывания правила
    for json_dict in g:
        if (json_dict['event_type'] in any_event_dict and json_dict['event_status'] != "STARTED"):
            TUMBLR = True
            # Вызов функции подготовки базовых полей
            result_prep_f = prepare_for_alert(json_dict)

    # Вызов отправки в телеграм, если есть сработка
    event_type = json_dict['event_type']
    if (TUMBLR):
        send_message(result_prep_f, event_type)


# --------Telegram
def send_message(text, event_type):
   # Для того, чтобы получить токен https://proglib.io/p/telegram-bot
   # Для получения chat-id сначала пишем хоть одно сообление боту, далее используем https://api.telegram.org/bot<token>/getUpdates
   # На входе для функции в vars вынести chat_id, token

    if event_type in ["yandex.cloud.audit.network.UpdateSecurityGroup", "yandex.cloud.audit.network.CreateSecurityGroup"]:
        result_text = '*⛔️ Detection rule* : "Create danger, ingress ACL in SG (0.0.0.0/0)":\n\n'
    elif event_type in ["yandex.cloud.audit.storage.BucketUpdate"]:
        result_text = '*⛔️ Detection rule* : "Change Bucket access to public":\n\n'
    elif event_type in ["yandex.cloud.audit.lockbox.UpdateSecretAccessBindings"]:
        result_text = '*⛔️ Detection rule* : "Assign rights to the secret (LockBox) to some account":\n\n'
    else:
        result_text = f'*⛔️ Detection rule on event* : "{event_type}":\n\n'

    for item in text:
        result_text = result_text + '*' + item + '*' + ': ' + text[item] + '\n'
    print(result_text)
    token = bot_token
    chat_id = chat_id_var
    url_req = "https://api.telegram.org/bot" + token + "/sendMessage" + \
        "?chat_id=" + chat_id + "&text=" + result_text + "&parse_mode=Markdown"
    results = requests.get(url_req)
    print(results.json())


# -----------------------------#Active remediation
# Get-token
def get_token():
    response = requests.get(
        'http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token', headers={"Metadata-Flavor": "Google"})
    return response.json().get('access_token')

# ----------
# Удаление sg правила
def del_rule(sg_id, sg_rule_id):
    token = get_token()
    request_json_data = {"deletionRuleIds": [f"{sg_rule_id}"]}
    response = requests.patch('https://vpc.api.cloud.yandex.net.yandex.net/vpc/v1/securityGroups/'+sg_id+'/rules',
                              data=json.dumps(request_json_data), headers={"Accept": "application/json", "Authorization": "Bearer "+token})

    print("START DEBUG--------------------------")
    print(response)
    print(request_json_data)
    print(token)
    print(response.request.url)
    print(response.request.body)
    print(response.request.headers)
    return response
    print("STOP DEBUG----------------")

# ----------
# Удаление назначенных прав на секрет
def del_perm_secret(secret_id, role_id, sa_id):
    token = get_token()
    request_json_data = {"accessBindingDeltas": [{"action": "REMOVE", "accessBinding": {
        "roleId": f"{role_id}", "subject": {"id": f"{sa_id}", "type": "serviceAccount"}}}]}
    response = requests.patch('https://lockbox.api.cloud.yandex.net/lockbox/v1/secrets/'+secret_id+':updateAccessBindings',
                              data=json.dumps(request_json_data), headers={"Accept": "application/json", "Authorization": "Bearer "+token})

    print("START DEBUG--------------------------")
    print(response)
    print(request_json_data)
    print(token)
    print(response.request.url)
    print(response.request.body)
    print(response.request.headers)
    return response
    print("STOP DEBUG----------------")


# -----------------------------
# Отладочная загрузка файла json руками, в случае вызова cloud-functions json файл сам передается в handler
'''
with open("create_sg_new.json", "r") as read_file:
    data = json.load(read_file)

handler(data, "d")
'''
