import base64
import boto3
import botocore
import json
import os
import requests
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
    b64_data            = response.json().get('plaintext')
    return base64.b64decode(b64_data).decode()

# Configuration - Get ElasticSearch CA.pem
def get_elastic_cert():
    file = 'include/CA.pem'
    if os.path.isfile(file):
        return file
    else:
        url = 'https://storage.yandexcloud.net/cloud-certs/CA.pem'
        response = requests.get(url)
        with open('include/CA.pem', 'wb') as f:
            f.write(response.content)
        return file


# Configuration - Keys
elastic_auth_pw_encr    = os.environ['ELK_PASS_ENCR']
kms_key_id              = os.environ['KMS_KEY_ID']
s3_key_encr             = os.environ['S3_KEY_ENCR']
s3_secret_encr          = os.environ['S3_SECRET_ENCR']


# Configuration - Setting up variables for ElasticSearch
elastic_auth_pw         = decrypt_secret_kms(elastic_auth_pw_encr)
elastic_auth_user       = os.environ['ELASTIC_AUTH_USER']
elastic_server          = os.environ['ELASTIC_SERVER']
kibana_server           = os.environ['KIBANA_SERVER']
elastic_cert            = get_elastic_cert()

# Configuration - Setting up variables for S3
s3_bucket               = os.environ['S3_BUCKET']
s3_key                  = decrypt_secret_kms(s3_key_encr)
s3_local                = '/tmp/data'
s3_secret               = decrypt_secret_kms(s3_secret_encr)

# Configuration - Sleep time
if(os.getenv('SLEEP_TIME') is not None):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

# Configuration - Log type
if os.getenv("AUDIT_LOG_PREFIX") is not None:
    s3_folder               = os.environ['AUDIT_LOG_PREFIX'].rstrip("/")
    elastic_index_name      = "k8s-audit"
elif os.getenv("FALCO_LOG_PREFIX") is not None:
    s3_folder               = os.environ['FALCO_LOG_PREFIX'].rstrip("/")
    elastic_index_name      = "k8s-falco"

# State - Setting up S3 client
s3 = boto3.resource('s3',
    endpoint_url            = 'https://storage.yandexcloud.net',
    aws_access_key_id       = s3_key,
    aws_secret_access_key   = s3_secret 
)

sqs = boto3.client(
    service_name            = 'sqs',
    endpoint_url            = 'https://message-queue.api.cloud.yandex.net',
    region_name             = 'ru-central1',
    aws_access_key_id       = s3_key,
    aws_secret_access_key   = s3_secret 
)

# Configuration - YMQ
sqs_url             = os.environ['YMQ_URL']


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
        print(f"{response.status_code} -- {response.text}")
    else:
        print('Config index -- EXISTS')
        print(f"{response.status_code} -- {response.text}")


# Function - Get config index state
def get_config_index_state():
    request_suffix  = f"/.state-{elastic_index_name}/_doc/1/_source"
    response        = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        return False
    return response.json()['is_configured']


# Function - Create ingest pipeline
def create_ingest_pipeline():
    if elastic_index_name == "k8s-audit":
        request_suffix  = '/_ingest/pipeline/k8s-pipeline'
        data_file       = open(f"include/{elastic_index_name}/pipeline.json") # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    elif elastic_index_name == "k8s-falco":
        request_suffix  = '/_ingest/pipeline/falco-pipeline'
        data_file       = open(f"include/{elastic_index_name}/pipeline.json") # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Ingest pipeline -- CREATED')
    print(f"{response.status_code} -- {response.text}")


# Function - Create an index with mapping
def create_index_with_map():
    request_suffix  = f"/{elastic_index_name}"
    data_file       = open(f"include/{elastic_index_name}/mapping.json") # заменить на прямую ссылку github когда репо станет публичным
    data_json       = json.load(data_file)
    data_file.close()
    response        = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index with mapping -- CREATED')
    print(f"{response.status_code} -- {response.text}")


# Function - Refresh index
def refresh_index():
    request_suffix  = f"/{elastic_index_name}/_refresh"
    response        = requests.post(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index -- REFRESHED')
    print(f"{response.status_code} -- {response.text}")


# Function - Preconfigure Kibana
def configure_kibana():
    # Index pattern
    file = f"include/{elastic_index_name}/index-pattern.ndjson"
    if os.path.isfile(file):
        data_file = {
            'file': open(file, 'rb')
        }
        request_suffix  = '/api/saved_objects/_import'
        response        = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
        if(response.status_code == 200):
            print('Index pattern -- IMPORTED')
        print(f"{response.status_code} -- {response.text}")

     # Filters
    file = f"include/{elastic_index_name}/filters.ndjson"
    if os.path.isfile(file):
        data_file = {
            'file': open(file, 'rb')
        }
        request_suffix = '/api/saved_objects/_import'
        response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
        if(response.status_code == 200):
            print('Filters -- IMPORTED')
        print(f"{response.status_code} -- {response.text}")

    # Search
    file = f"include/{elastic_index_name}/search.ndjson"
    if os.path.isfile(file):
        data_file = {
            'file': open(file, 'rb')
        }
        request_suffix = '/api/saved_objects/_import'
        response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
        if(response.status_code == 200):
            print('Searches -- IMPORTED')
        print(f"{response.status_code} -- {response.text}")

    # Dashboard
    file = f"include/{elastic_index_name}/dashboard.ndjson"
    if os.path.isfile(file):
        data_file = {
            'file': open(file, 'rb')
        }
        request_suffix = '/api/saved_objects/_import'
        response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
        if(response.status_code == 200):
            print('Dashboard -- IMPORTED')
        print(f"{response.status_code} -- {response.text}")

    # Detections (not stable, throws error 400 from time to time)
    file = f"include/{elastic_index_name}/detections.ndjson"
    if os.path.isfile(file):
        data_file = {
            'file': open(file, 'rb')
        }
        request_suffix = '/api/detection_engine/rules/_import'
        response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
        if(response.status_code == 200):
            print('Detections -- IMPORTED')
        print(f"{response.status_code} -- {response.text}")

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


# Function - Delete SQS message
def delete_sqs_message(msg):
    sqs.delete_message(
        QueueUrl=sqs_url,
        ReceiptHandle=msg.get('ReceiptHandle')
    )


# Function - Process JSON logs batch
def process_s3_batch(bucket, folder, local=None):
    print('JSON processing -- STARTED')

    parse_substring = '".": {}, '

    processing          = True

    if elastic_index_name == "k8s-audit":
        request_suffix      = f"/{elastic_index_name}/_bulk?pipeline=k8s-pipeline"
    elif elastic_index_name == "k8s-falco":
        request_suffix      = f"/{elastic_index_name}/_bulk?pipeline=falco-pipeline"
    
    while processing:

        b = s3.Bucket(bucket)

        messages = sqs.receive_message(
            QueueUrl=sqs_url,
            MaxNumberOfMessages=10,
            VisibilityTimeout=60,
            WaitTimeSeconds=20
        ).get('Messages')
        
        if(messages == None):
            processing = False
            continue

        for msg in messages:
            msg_body    = json.loads(msg.get('Body'))
            source      = msg_body['object_id']
            cloud_id    = msg_body['cloud_id']
            folder_id   = msg_body['folder_id']
            cluster_id  = msg_body['cluster_id']
            cluster_url = msg_body['cluster_url']

            if source[-1] == '/':
                delete_sqs_message(msg)
                continue
            
            target = source if local is None \
                else os.path.join(local, source)
            if not os.path.exists(os.path.dirname(target)):
                os.makedirs(os.path.dirname(target))

            try:
                b.download_file(source, target)
            except botocore.exceptions.ClientError as e:
                sqs.delete_message(
                    QueueUrl=sqs_url,
                    ReceiptHandle=msg.get('ReceiptHandle')
                )
                continue

            with open(target, "r") as raw_file:
                lines = []
                for line in raw_file:
                    lines.append('{"index":{}},')
                    line = line.replace(parse_substring, "")
                    lines.append(f"{line.rstrip()[:-1]}, \"cloud_id\": \"{cloud_id}\", \"folder_id\": \"{folder_id}\", \"cluster_id\": \"{cluster_id}\", \"cluster_url\": \"{cluster_url}\"}},")
                lines[-1] = lines[-1][:-1]+"\n"
                data = "\n".join(lines)
            
            response = requests.post(elastic_server+request_suffix, \
                data=data, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), \
                    headers={"Content-Type":"application/json"})
            
            if(response.status_code == 200):
                delete_object_s3(s3_bucket, source)
                delete_sqs_message(msg)
                os.remove(target)
                print(response.text)
            else:
                print(response.text)

    print(f"JSON processing -- COMPLETE")

# Process - Upload data
def upload_logs():
    if(get_config_index_state()):
        print("Config index -- EXISTS")
        process_s3_batch(s3_bucket, s3_folder, s3_local)
        refresh_index()
    else:
        create_index_with_map()
        create_ingest_pipeline()
        configure_kibana()
        create_config_index()
        process_s3_batch(s3_bucket, s3_folder, s3_local)
        refresh_index()


### MAIN CONTROL PANEL

upload_logs()
print("Sleep -- STARTED")
time.sleep(sleep_time)