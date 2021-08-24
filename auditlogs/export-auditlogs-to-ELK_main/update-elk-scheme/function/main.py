import base64
import json
import os
import requests


# function - get token
def get_token():
    response = requests.get('http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token', headers={"Metadata-Flavor":"Google"})
    return response.json().get('access_token')


# function - decrypt data with kms key
def decrypt_secret_kms(secret):
    token               = get_token()
    request_suffix      = kms_key_id+':decrypt'
    request_json_data   = {'ciphertext': secret}
    response            = requests.post('https://kms.yandex/kms/v1/keys/'+request_suffix, data=json.dumps(request_json_data), headers={"Accept":"application/json", "Authorization": "Bearer "+token})
    b64_data            = response.json().get('plaintext')
    return base64.b64decode(b64_data).decode()


# configuration - get elasticsearch certificate
def get_elastic_cert():
    file = '/app/CA.pem'
    if os.path.isfile(file):
        return file
    else:
        url = 'https://storage.yandexcloud.net/cloud-certs/CA.pem'
        response = requests.get(url)
        with open('/app/CA.pem', 'wb') as f:
            f.write(response.content)
        return file

# configuration - keys
# elastic_auth_pw_encr    = os.environ['ELK_PASS_ENCR']
# kms_key_id              = os.environ['KMS_KEY_ID']


# Configuration - Setting up variables for ElasticSearch
# elastic_auth_pw         = decrypt_secret_kms(elastic_auth_pw_encr)
elastic_auth_user       = os.environ['ELASTIC_AUTH_USER']
elastic_server          = f"{os.environ['KIBANA_SERVER']}:9200"
kibana_server           = os.environ['KIBANA_SERVER']
elastic_auth_pw         = os.environ['ELASTIC_AUTH_PW']
elastic_cert            = get_elastic_cert()


# function - get config index state
def get_config_index_state(index):
    request_suffix  = f"/.state-{index}/_doc/1/_source"
    response        = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        print(response.text)
        return False
    return response.json()['is_configured']

# state - existing config indexes
config_states = {
    "audit-trail": get_config_index_state("audit-trails-index"),
    "k8s-audit": get_config_index_state("k8s-audit"),
    "k8s-falco": get_config_index_state("k8s-falco")
}


# function - refresh index patterns
def refresh_index_pattern(key):
    # get current index-pattern file
    file = f"include/{key}/index-pattern.ndjson"
    # check ndjson file exists
    if not os.path.isfile(file):
        return 
    # open ndjson file
    data_file = {
        'file': open(file, 'rb')
    }
    # import ndjson file
    request_suffix  = '/api/saved_objects/_import?overwrite=True'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(f"{response.status_code} -- INDEX PATTERN(S) REFRESHED")
    print(response.text)


# function - refresh filters
def refresh_filters(key):
    file = f"include/{key}/filters.ndjson"
    # check ndjson file exists
    if not os.path.isfile(file):
        return 
    # open ndjson file
    data_file = {
        'file': open(file, 'rb')
    }
    # import ndjson file
    request_suffix  = '/api/saved_objects/_import?overwrite=True'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(f"{response.status_code} -- FILTER(S) REFRESHED")
    print(response.text)


# function - refresh searches
def refresh_searches(key):
    file = f"include/{key}/search.ndjson"
    # check ndjson file exists
    if not os.path.isfile(file):
        return 
    # open ndjson file
    data_file = {
        'file': open(file, 'rb')
    }
    # import ndjson file
    request_suffix  = '/api/saved_objects/_import?overwrite=True'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(f"{response.status_code} -- SEARCH(ES) REFRESHED")
    print(response.text)


# function - refresh dashboards
def refresh_dashboards(key):
    file = f"include/{key}/dashboard.ndjson"
    # check ndjson file exists
    if not os.path.isfile(file):
        return 
    # open ndjson file
    data_file = {
        'file': open(file, 'rb')
    }
    # import ndjson file
    request_suffix  = '/api/saved_objects/_import?overwrite=True'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(f"{response.status_code} -- DASHBOARD(S) REFRESHED")
    print(response.text)


# function - refresh dashboards
def refresh_detections(key):
    file = f"include/{key}/detections.ndjson"
    # check ndjson file exists
    if not os.path.isfile(file):
        return 
    # open ndjson file
    data_file = {
        'file': open(file, 'rb')
    }
    # import ndjson file
    request_suffix  = '/api/detection_engine/rules/_import?overwrite=True'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(f"{response.status_code} -- DETECTION(S) REFRESHED")
    print(response.text)


# main loop
for key,value in config_states.items():
    # loop through index patterns if index exists
    if value == False:
        continue

    refresh_index_pattern(key)
    refresh_filters(key)
    refresh_searches(key)
    refresh_dashboards(key)
    refresh_detections(key)