"""
Script to migrate secrets from Hashicorp Vault to Yandex Cloud Lockbox service
command line options
-l --list                   : dump Vault secrets to screen
-o --outFile [FILENAME]     : save Vault secrets to file [file name by default - secrets.json]
-m --migrate                : migrate all secrets from Vault to Lockbox
-c --createFrom [FILENAME]  : create secrets in Lockbox from file [file name by default - secrets.json]
-d --deleteAll                 : delete all secrets in Lockbox

To work properly, script need read config values. It's recommended to create .env file in the same directory as the script
with the following content:

VAULT_TOKEN = "00000000-0000-0000-0000-000000000000"
VAULT_URL = "https://localhost:8201"
VAULT_ROOT_PATH = "<your root path of secret store>"
VAULT_KV_VERSION = 2
VAULT_VERIFY_SSL = False
YC_TOKEN = "<insert yc toket (yc iam create token)>"
YANDEX_FOLDER_ID = "<yandex cloud folder where Lockbox service will create your secrets>"
OUT_FILE = "secrets.json"
INPUT_FILE = "secrets.json"

"""

import requests
import json
import os
from dotenv import load_dotenv
import urllib.request, ssl, urllib.error
import urllib3
import sys
import getopt

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

g_vault_token = ""
g_vault_url = ""
g_vault_root_path = ""
g_vault_kv_version = 2
g_vault_verify_ssl = False
g_yandex_token = ""
g_yandex_folder_id = ""
g_yandex_url = "https://lockbox.api.cloud.yandex.net/lockbox/v1/secrets"
g_out_file = "secrets.json"
g_input_file = "secrets.json"

g_secrets = {}


# List Vault keys
def vault_list_keys(root):
    url = f'{g_vault_url}/v1/{g_vault_root_path}/metadata/{root}'
    # print(f"Vault URL={url}")

    if g_vault_verify_ssl:
        opener = urllib.request.build_opener(urllib.request.HTTPHandler)
    else:
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx), urllib.request.HTTPHandler)

    request = urllib.request.Request(url)
    request.add_header("X-Vault-Token", g_vault_token)
    request.get_method = lambda: 'LIST'
    try:
        response = opener.open(request)
        data = response.read()
        data_json = json.loads(data)
        # print(data_json["data"]["keys"])
        for key in data_json["data"]["keys"]:
            if key[-1] == '/':
                vault_list_keys(root + key)
            else:
                vault_get_metadata(root + key)
    except urllib.error.HTTPError as err:
        print(f'A HTTPError was thrown: {err.code} {err.reason}')
    except urllib.error.URLError as err:
        print(f'A URLError was thrown: {err=}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def vault_get_secrets(path, version, current_version, custom_metadata):
    url = f'{g_vault_url}/v1/{g_vault_root_path}/data/{path}?version={version}'
    headers = {'X-Vault-Token': g_vault_token}
    try:
        request = requests.get(url, headers=headers, verify=g_vault_verify_ssl)
        key_data = json.loads(request.text)
        if path not in g_secrets:
            g_secrets[path] = []
        key_data['data']['metadata']['current_version'] = current_version
        g_secrets[path].append(key_data)
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err=}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def vault_get_metadata(path):
    url = f'{g_vault_url}/v1/{g_vault_root_path}/metadata/{path}'
    headers = {'X-Vault-Token': g_vault_token}
    try:
        request = requests.get(url, headers=headers, verify=g_vault_verify_ssl)
        for item in request.json()['data']['versions']:
            if not request.json()['data']['versions'][item]['destroyed']:
                vault_get_secrets(path,
                                  item,
                                  request.json()['data']['current_version'],
                                  request.json()['data']['custom_metadata'])
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err=}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_prepare_secrets_from_file():
    try:
        with open(g_input_file) as f:
            t_dict = json.load(f)
            if t_dict:
                for key in t_dict:
                    for secret in t_dict[key]:
                        if secret["data"]["metadata"]["version"] == secret["data"]["metadata"]["current_version"]:
                            yandex_create_secrets(key, secret)
    except FileNotFoundError as err:
        print(f'Input file "{g_input_file}" is not found.')
    except json.JSONDecodeError as err:
        print(f'Can not parse input file "{g_input_file}". Check JSON syntax.')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_prepare_secrets_from_var():
    try:
        if g_secrets:
            for key in g_secrets:
                for secret in g_secrets[key]:
                    if secret["data"]["metadata"]["version"] == secret["data"]["metadata"]["current_version"]:
                        yandex_create_secrets(key, secret)
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_create_secrets(path, secret_json):
    url = g_yandex_url
    headers = {"Authorization": f"Bearer {g_yandex_token}"}
    payload_dict = {}
    empty_dict = {}
    try:
        payload_dict["folderId"] = g_yandex_folder_id
        payload_dict["name"] = path
        payload_dict["versionDescription"] = ""
        payload_dict["description"] = ""
        payload_dict["labels"] = empty_dict
        payload_dict["kmsKeyId"] = ""
        payload_dict["deletionProtection"] = False
        payload_dict["versionPayloadEntries"] = yandex_create_secret_payloads(secret_json)
        request = requests.post(url, headers=headers, data=json.dumps(payload_dict))
        if request.status_code == 200:
            print_data = json.loads(request.text)
            print(f'Secret {print_data["response"]["name"]} has created with id={print_data["metadata"]["secretId"]}')
        else:
            print(f'Error. {json.loads(request.text)["message"]}')
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_create_secret_payloads(secret_dict):
    t_arr = []
    if len(secret_dict) == 0:
        return t_arr
    for key in secret_dict["data"]["data"]:
        if isinstance(secret_dict["data"]["data"][key], dict):
            t_arr.append({"key": "data", "textValue": f'{secret_dict["data"]["data"]}'})
            return t_arr
    for key in secret_dict["data"]["data"]:
        t_arr.append({"key": key, "textValue": secret_dict["data"]["data"][key]})
    return t_arr


def yandex_get_secrets():
    secret_id = "XXXXX"
    url = f"https://lockbox.api.cloud.yandex.net/lockbox/v1/secrets/{secret_id}"
    headers = {"Authorization": f"Bearer {g_yandex_token}"}
    print(headers)
    try:
        request = requests.get(url, headers=headers)
        print(request.json())
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err=}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_create_simple_secrets():
    # Функция для создания одного секрета с заданными параметрами
    headers = {"Authorization": f"Bearer {g_yandex_token}"}
    payload_dict = {}
    # Если метки не нужны, оставьте этот словарь пустым, это необходимо для правильной работы запроса
    # !!! весь текст внутри labels_dict должен быть маленькими буквами и без пробелов
    labels_dict = {"label1": "label1_data", "label2": "label2_data"}
    t_arr = []
    try:
        payload_dict["folderId"] = g_yandex_folder_id
        payload_dict["name"] = "test"
        payload_dict["description"] = ""
        payload_dict["labels"] = labels_dict
        payload_dict["kmsKeyId"] = ""
        payload_dict["versionDescription"] = ""
        payload_dict["deletionProtection"] = False
        t_arr.append({"key": "FirstKey", "textValue": "password1"})
        t_arr.append({"key": "SecondKey", "textValue": "password2"})
        payload_dict["versionPayloadEntries"] = t_arr
        # можно сохранить в файл для дальнейших тестов с curl
        # curl -X POST -d @./lockbox_simple_secret.json -H "Authorization: Bearer <Token>" https://lockbox.api.cloud.yandex.net/lockbox/v1/secrets
        # with open("lockbox_simple_secret.json", 'w') as f:
        #    json.dump(payload_dict, f, indent=4)
        print(payload_dict)
        request = requests.post(g_yandex_url, headers=headers, data=json.dumps(payload_dict))
        request.raise_for_status()
        print(request.text)
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def yandex_delete_all_secrets():
    # Функция для удаления всех секретов в Lockbox Есть ограничения - по умолчанию происходит запрос 100 секретов за
    # один раз, если нужно больше, нужно менять параметры листинга секретов
    get_confirmation("This action will delete ALL secrets from Lockbox. Continue?")

    headers = {"Authorization": f"Bearer {g_yandex_token}"}
    params = {"folderId": g_yandex_folder_id}
    update_string = '{"updateMask": "deletionProtection","deletionProtection": false}'
    try:
        request = requests.get(g_yandex_url, headers=headers, params=params)
        if request.status_code == 200:
            if len(json.loads(request.text)) > 0:
                for item in request.json()["secrets"]:
                    # Сначала, если есть, убираем запрет на удаление
                    if item["deletionProtection"]:
                        print(f'Update delete protection for secretId {item["id"]}')
                        u_request = requests.patch(f'{g_yandex_url}/{item["id"]}', headers=headers, data=update_string)
                        u_request.raise_for_status()
                    print(f'Delete secret with secretId {item["id"]}')
                    d_request = requests.delete(f'{g_yandex_url}/{item["id"]}', headers=headers)
                    d_request.raise_for_status()
            else:
                print(f'There are no secrets in Lockbox service.')
        else:
            print(f'Error. {json.loads(request.text)["message"]}')
    except requests.HTTPError as err:
        print(f'A HTTPError was thrown: {err=}')
    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")


def get_confirmation(prompt):
    answer = ""
    while answer not in ["y", "n"]:
        answer = input(f"{prompt} [Y/N]? ").lower()
    if answer == "n":
        sys.exit(0)


def dump_to_screen():
    # List all secrets to screen
    vault_list_keys('')
    print(json.dumps({**{}, **g_secrets}, indent=2))


def save_to_file():
    if os.path.isfile(g_out_file):
        get_confirmation(f"File {g_out_file} exist. Overwrite it?")

    vault_list_keys('')
    t_str = json.dumps(g_secrets, indent=4)
    with open(g_out_file, 'w') as f:
        print(t_str, file=f)
    print(f"File {g_out_file} has created.")


def migrate():
    vault_list_keys('')
    print(json.dumps({**{}, **g_secrets}, indent=2))
    get_confirmation("Need your confirmation to create this secrets in Lockbox service. Continue?")
    yandex_prepare_secrets_from_var()


def create_secrets():
    if os.path.isfile(g_input_file):
        get_confirmation(
            f"Need your confirmation to create secrets from file {g_input_file} in Lockbox service. Continue?")
        yandex_prepare_secrets_from_file()
    else:
        print(f"File {g_input_file} is not exist.")


def print_help():
    print("Script to migrate secrets from Hashicorp Vault to Yandex Cloud Lockbox service")
    print("Command line arguments:")
    print("-h                             : this help")
    print("-l or --list                   : dump Vault secrets to screen")
    print("-o or --outFile [FILENAME]     : save Vault secrets to file [file name by default - secrets.json]")
    print("-m or --migrate                : migrate all secrets from Vault to Lockbox")
    print("-c or --createFrom [FILENAME]  : create secrets in Lockbox from file [file name by default - secrets.json]")
    print("-d or --deleteAll                : delete all secrets in Lockbox")


def load_config():
    global g_vault_token
    global g_vault_url
    global g_vault_root_path
    global g_vault_kv_version
    global g_vault_verify_ssl
    global g_yandex_token
    global g_yandex_folder_id
    global g_yandex_url
    global g_out_file
    global g_input_file

    load_dotenv()
    exit_flag = False

    # print(json.dumps({**{}, **os.environ}, indent=2))

    g_vault_token = os.environ.get("VAULT_TOKEN", "")
    if len(g_vault_token) == 0:
        print("Error. Set VAULT_TOKEN environment variable. For example, export VAULT_TOKEN=$(vault token create).")
        exit_flag = True

    g_vault_url = os.environ.get("VAULT_URL", "")
    if len(g_vault_url) == 0:
        print("Error. Set VAULT_URL environment variable. For example, export VAULT_URL=https://localhost:8201")
        exit_flag = True

    g_vault_root_path = os.environ.get("VAULT_ROOT_PATH", "")
    if len(g_vault_root_path) == 0:
        print("Error. Set VAULT_ROOT_PATH environment variable. For example, export VAULT_ROOT_PATH=secret")
        exit_flag = True

    g_yandex_token = os.environ.get("YC_TOKEN", "")
    if len(g_yandex_token) == 0:
        print("Error. Set YC_TOKEN environment variable. For example, export YC_TOKEN=$(yc iam create-token).")
        exit_flag = True

    g_yandex_folder_id = os.environ.get("YANDEX_FOLDER_ID", "")
    if len(g_yandex_folder_id) == 0:
        print("Error. Set YANDEX_FOLDER_ID environment variable. For example, export YANDEX_FOLDER_ID=123456789")
        exit_flag = True

    g_yandex_url = os.environ.get("YANDEX_URL", "https://lockbox.api.cloud.yandex.net/lockbox/v1/secrets")

    g_out_file = os.environ.get("OUT_FILE", "secrets.json")
    g_input_file = os.environ.get("INPUT_FILE", "secrets.json")

    try:
        g_vault_kv_version = int(os.environ.get("VAULT_KV_VERSION", "2"))
        if not (g_vault_kv_version == 1 or g_vault_kv_version == 2):
            print(f"Possible values of VAULT_KV_VERSION must be 1 or 2")
            exit_flag = True
    except Exception as err:
        print(f"Possible values of VAULT_KV_VERSION must be 1 or 2")
        exit_flag = True

    test_string = os.environ.get("VAULT_VERIFY_SSL", False)
    if test_string == "False":
        g_vault_verify_ssl = False
    elif test_string == "True":
        g_vault_verify_ssl = True
    else:
        print(f"Possible values of VAULT_VERIFY_SSL must be True or False")
        exit_flag = True

    if exit_flag:
        sys.exit(1)


if __name__ == '__main__':

    if len(sys.argv) == 1:
        print_help()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hlomcd",
                                   ["help", "list", "outFile", "migrate", "createFrom", "deleteAll"])
    except getopt.GetoptError:
        print_help()
        sys.exit(2)

    if len(opts) > 1:
        print("Specify only one command line argument.")
        sys.exit(0)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print_help()
            sys.exit()
        elif opt in ("-l", "--list"):
            load_config()
            dump_to_screen()
        elif opt in ("-o", "--outFile"):
            load_config()
            if len(sys.argv) > 2:
                g_out_file = sys.argv[2]            ч
            save_to_file()
        elif opt in ("-m", "--migrate"):
            load_config()
            migrate()
        elif opt in ("-c", "--createFrom"):
            load_config()
            if len(sys.argv) > 2:
                g_input_file = sys.argv[2]
            create_secrets()
        elif opt in ("-d", "--deleteAll"):
            load_config()
            yandex_delete_all_secrets()
        else:
            print_help()
            sys.exit()
