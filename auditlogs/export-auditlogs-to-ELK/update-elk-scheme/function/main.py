import base64
import json
import os
import requests


# Проверить какие .state индексы существуют
# На основе этого парсить нужные папки в include
# в каждом файле взять строку и найти по id объект и сравнить
# Если отличается - удалить и импортировать
# Если не отличается - continue


# Function - Get token
def get_token():
    response = requests.get('http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token', headers={"Metadata-Flavor":"Google"})
    return response.json().get('access_token')


# Function - Decrypt data with KMS key
def decrypt_secret_kms(secret):
    token               = get_token()
    request_suffix      = kms_key_id+':decrypt'
    request_json_data   = {'ciphertext': secret}
    response            = requests.post('https://kms.yandex/kms/v1/keys/'+request_suffix, data=json.dumps(request_json_data), headers={"Accept":"application/json", "Authorization": "Bearer "+token})
    b64_data            = response.json().get('plaintext')
    return base64.b64decode(b64_data).decode()


# Configuration - Get ElasticSearch CA.pem
def get_elastic_cert():
    file = 'CA.pem'
    if os.path.isfile(file):
        return file
    else:
        url = 'https://storage.yandexcloud.net/cloud-certs/CA.pem'
        response = requests.get(url)
        with open('CA.pem', 'wb') as f:
            f.write(response.content)
        return file

# Configuration - Keys
# elastic_auth_pw_encr    = os.environ['ELK_PASS_ENCR']
# kms_key_id              = os.environ['KMS_KEY_ID']


# Configuration - Setting up variables for ElasticSearch
# elastic_auth_pw         = decrypt_secret_kms(elastic_auth_pw_encr)
# elastic_auth_user       = os.environ['ELASTIC_AUTH_USER']
# elastic_server          = os.environ['ELASTIC_SERVER']
# kibana_server           = os.environ['KIBANA_SERVER']
elastic_auth_pw         = "elasticsearch123"
elastic_auth_user       = "admin"
elastic_server          = "https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net:9200"
kibana_server           = "https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net"
elastic_cert            = get_elastic_cert()


# Function - Get config index state
def get_config_index_state(index):
    request_suffix  = f"/.state-{index}/_doc/1/_source"
    response        = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        print(response.text)
        return False
    print(response.text)
    return response.json()['is_configured']


# State - Existing config indexes
config_states = {
    "audit-trail": get_config_index_state("audit-trails-index"),
    "k8s-audit": get_config_index_state("k8s-audit"),
    "k8s-falco": get_config_index_state("k8s-falco")
}

for k,v in config_states.items():
    # Loop through index patterns
    if v == True:
        file = f"../include/{k}/index-pattern.ndjson"
        if os.path.isfile(file):
            data_file = {
                'file': open(file, 'rb')
            }
            request_suffix  = '/api/saved_objects/_import'
            response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
            if(response.status_code == 200):
                print('Index pattern -- IMPORTED')