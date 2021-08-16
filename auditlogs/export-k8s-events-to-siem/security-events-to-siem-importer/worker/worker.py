import requests
import json
import os
import boto3
import botocore


# Configuration - Setting up variables for ElasticSearch
elastic_auth_pw         = os.environ['ELASTIC_AUTH_PW']
elastic_auth_user       = os.environ['ELASTIC_AUTH_USER']
elastic_server          = f"{os.environ['ELASTIC_SERVER']}:9200"
kibana_server           = os.environ['ELASTIC_SERVER']

# Configuration - Setting up variables for S3
s3_bucket               = os.environ['S3_BUCKET']
s3_key                  = os.environ['AWS_ACCESS_KEY_ID']
s3_local                = '/tmp/data'
s3_secret               = os.environ['AWS_SECRET_ACCESS_KEY']

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
    response        = requests.get(elastic_server+request_suffix, verify=False, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 404):
        request_suffix = f"/.state-{elastic_index_name}/_doc/1"
        request_json = """{
            "is_configured": true
        }"""
        response = requests.post(elastic_server+request_suffix, data=request_json, verify=False, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index -- CREATED')
    else:
        print('Config index -- EXISTS')


# Function - Get config index state
def get_config_index_state():
    request_suffix  = f"/.state-{elastic_index_name}/_doc/1/_source"
    response        = requests.get(elastic_server+request_suffix, verify=False, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        return False
    return response.json()['is_configured']


# Function - Create ingest pipeline
def create_ingest_pipeline():
    if elastic_index_name == "k8s-audit":
        request_suffix  = '/_ingest/pipeline/k8s-pipeline'
        data_file       = open('include/auditlog/pipeline.json') # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    elif elastic_index_name == "k8s-falco":
        request_suffix  = '/_ingest/pipeline/falco-pipeline'
        data_file       = open('include/falco/pipeline.json') # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=False, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Ingest pipeline -- CREATED')


# Function - Create an index with mapping
def create_index_with_map():
    if elastic_index_name == "k8s-audit":
        request_suffix  = f"/{elastic_index_name}"
        data_file       = open('include/auditlog/mapping.json') # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    elif elastic_index_name == "k8s-falco":
        request_suffix  = f"/{elastic_index_name}"
        data_file       = open('include/falco/mapping.json') # заменить на прямую ссылку github когда репо станет публичным
        data_json       = json.load(data_file)
        data_file.close()
    response        = requests.put(elastic_server+request_suffix, json=data_json, verify=False, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index with mapping -- CREATED')


# Function - Refresh index
def refresh_index():
    request_suffix  = f"/{elastic_index_name}/_refresh"
    response        = requests.post(elastic_server+request_suffix, verify=False, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index -- REFRESHED')


# Function - Preconfigure Kibana
def configure_kibana():
    # Index pattern
    if elastic_index_name == "k8s-audit":
        data_file = {
            'file': open('include/auditlog/index-pattern.ndjson', 'rb')
        }
    elif elastic_index_name == "k8s-falco":
        data_file = {
            'file': open('include/falco/index-pattern.ndjson', 'rb')
        }
    request_suffix  = '/api/saved_objects/_import'
    response        = requests.post(kibana_server+request_suffix, files=data_file, verify=False, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    if(response.status_code == 200):
        print('Index pattern -- IMPORTED')


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
            msg_body = json.loads(msg.get('Body'))
            source = msg_body['object_id']

            if source[-1] == '/':
                delete_sqs_message(msg)
                continue
                
            target = source if local is None \
                else os.path.join(local, source)
            if not os.path.exists(os.path.dirname(target)):
                os.makedirs(os.path.dirname(target))

            try:
                print(f"source: {source}, target: {target}")
                b.download_file(source, target)
            except botocore.exceptions.ClientError as e:
                sqs.delete_message(
                    QueueUrl=sqs_url,
                    ReceiptHandle=msg.get('ReceiptHandle')
                )
                continue

            #file_cloud_id   = msg.get('Body')['cloud_id']

            with open(target, "r") as raw_file:
                lines = []
                for line in raw_file:
                    lines.append('{"index":{}},')
                    #lines.append(line.rstrip()[:-1]+', "cloud_id": "'+file_cloud_id+'"},')
                    lines.append(line.rstrip()+",")
                lines[-1] = lines[-1][:-1]+"\n"
                data = "\n".join(lines)
            
            response = requests.post(elastic_server+request_suffix, data=data, verify=False, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
            
            if(response.status_code == 200):
                delete_object_s3(s3_bucket, source)
                delete_sqs_message(msg)
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


def handler(event, context):
    upload_logs()