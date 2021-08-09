import requests
import json
import os
import boto3
import time

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
    return response.json().get('plaintext')

# Configuration - Keys
kms_key_id              = "xxx"
elastic_auth_pw_encr    = "xxx"
s3_key_encr             = "xxx"
s3_secret_encr          = "xxx"

# Configuration - Setting up variables for ElasticSearch
elastic_server      = os.environ['ELASTIC_SERVER']
elastic_auth_user   = os.environ['ELASTIC_AUTH_USER']
elastic_auth_pw     = os.environ['ELASTIC_AUTH_PW']
elastic_index_name  = "k8s-audit"
kibana_server       = os.environ['KIBANA_SERVER']
elastic_cert        = 'include/ca.pem'

# Configuration - Setting up variables for S3
s3_key              = os.environ['S3_KEY']
s3_secret           = os.environ['S3_SECRET']
s3_bucket           = os.environ['S3_BUCKET']
s3_folder           = "AUDIT"
s3_local            = '/tmp/data/AUDIT'

# Configuration - Sleep time
if(os.getenv('SLEEP_TIME') is not None):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

# State - Setting up S3 client
s3 = boto3.resource('s3',
    endpoint_url            = 'https://storage.yandexcloud.net',
    aws_access_key_id       = s3_key,
    aws_secret_access_key   = s3_secret 
)

# Function - Create config index in ElasticSearch
def create_config_index():
    request_suffix  = f"/.state-{elastic_index_name}"
    response        = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 404):
        request_suffix = f"/.state-{elastic_index_name}/_doc/1"
        request_json = """{
            "is_configured": true
        }"""
        response = requests.post(elastic_server+request_suffix, data=request_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index -- CREATED')
    else:
        print('Config index -- EXISTS')

# Function - Get config index state
def get_config_index_state():
    request_suffix  = f"/.state-{elastic_index_name}/_doc/1/_source"
    response        = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        return False
    return response.json()['is_configured']

# Function - Create ingest pipeline
def create_ingest_pipeline():
    request_suffix  = '/_ingest/pipeline/k8s-pipeline'
    data_file       = open('include/pipeline.json')
    data_json       = json.load(data_file)
    data_file.close()
    response        = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Ingest pipeline -- CREATED')

# Function - Create an index with mapping
def create_index_with_map():
    request_suffix  = f"/{elastic_index_name}"
    data_file       = open('include/mapping.json')
    data_json       = json.load(data_file)
    data_file.close()
    response        = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index with mapping -- CREATED')

# Function - Refresh index
def refresh_index():
    request_suffix  = f"/{elastic_index_name}/_refresh"
    response        = requests.post(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    print('Index -- REFRESHED')
    print(response.status_code)
    print(response.text)

# Function - Preconfigure Kibana
def configure_kibana():
    # Index pattern
    data_file = {
        'file': open('include/index-pattern.ndjson', 'rb')
    }
    request_suffix  = '/api/saved_objects/_import'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    if(response.status_code == 200):
        print('Index pattern -- IMPORTED')
        print(response.status_code)
        print(response.text)
    print(response.status_code)
    print(response.text)

# Function - Download JSON logs to local folder
def download_s3_folder(bucket, folder, local=None):
    print('JSON download -- STARTED')
    b = s3.Bucket(bucket)
    if not os.path.exists(local):
            os.makedirs(local)
    for obj in b.objects.filter(Prefix=folder):
        target = obj.key if local is None \
            else os.path.join(local, os.path.relpath(obj.key, folder))
        if not os.path.exists(os.path.dirname(target)):
            os.makedirs(os.path.dirname(target))
        if obj.key[-1] == '/':
            continue
        b.download_file(obj.key, target)
    print('JSON download -- COMPLETE')

# Function - Clean up S3 folder
def delete_object_s3(s3_bucket, s3_object):
    b = s3.Bucket(s3_bucket)
    b.delete_objects(
        Delete={
            'Objects': [
                {
                    'Key': s3_object
                },
            ]
        }
    )

# Function - Upload logs to ElasticSearch
def upload_docs_bulk():
    print('JSON upload -- STARTED')
    error_count = 0
    request_suffix = f"/{elastic_index_name}/_bulk?pipeline=k8s-pipeline"

    for path, subdirs, files in os.walk(s3_local):
        for name in files:
            file            = os.path.join(path, name)
            path_list       = path.split('/')
            path_list       = path_list[path_list.index("AUDIT")+1:]
            file_cloud_id   = path_list[0]

            with open(file, "r") as raw_file:
                lines = []
                for line in raw_file:
                    lines.append('{"index":{}},')
                    lines.append(line.rstrip()[:-1]+', "cloud_id": "'+file_cloud_id+'"},')
                lines[-1] = lines[-1][:-1]+"\n"
                data = "\n".join(lines)
            response = requests.post(elastic_server+request_suffix, data=data, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
            if(response.status_code == 200):
                delete_object_s3(s3_bucket, s3_folder+file[len(s3_local):])
                os.remove(file)
            else:
                error_count += 1
                print(response.text)
    
    print('JSON upload -- COMPLETE -- %s ERRORS' % error_count)

# Process - Upload data
def upload_logs():
    if(get_config_index_state()):
        print("Config index -- EXISTS")
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk()
        refresh_index()
    else:
        create_index_with_map()
        create_ingest_pipeline()
        configure_kibana()
        create_config_index()
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk()
        refresh_index()

### MAIN CONTROL PANEL

upload_logs()
# create_ingest_pipeline()
# create_index_with_map()
# get_config_index_state()
# update_config_index_state()
# get_config_index_state()
# download_s3_folder(s3_bucket, s3_folder, s3_local)
# upload_docs_bulk()
# upload_docs_bulk()
# refresh_index()
print("Sleep -- STARTED")
time.sleep(sleep_time)