import requests
import json
import os
import boto3
import time

# Configuration - Setting up variables for ElasticSearch
elastic_server      = os.environ['ELASTIC_SERVER']
elastic_auth_user   = os.environ['ELASTIC_AUTH_USER']
elastic_auth_pw     = os.environ['ELASTIC_AUTH_PW']
elastic_index_name  = os.environ['ELASTIC_INDEX_NAME']
kibana_server       = os.environ['KIBANA_SERVER']
elastic_cert        = 'include/ca.pem'

# Configuration - Setting up variables for S3
s3_key              = os.environ['S3_KEY']
s3_secret           = os.environ['S3_SECRET']
s3_bucket           = os.environ['S3_BUCKET']
s3_folder           = os.environ['S3_FOLDER']
s3_local            = './temp'

# Configuration - Sleep time
if(os.environ['SLEEP_TIME']):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

# State - Setting up S3 client
s3 = boto3.resource('s3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id = s3_key,
    aws_secret_access_key = s3_secret 
)

# Function - Create config index in ElasticSearch
def create_config_index():
    request_suffix = '/.state-'+elastic_index_name
    response = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 404):
        request_suffix = '/.state-'+elastic_index_name+'/_doc/1'
        request_json = """{
            "is_configured": true
        }"""
        response = requests.post(elastic_server+request_suffix, data=request_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index has been created successfully.')
    else:
        print('Config index already exist.')

# Function - Get config index state
def get_config_index_state():
    request_suffix = '/.state-'+elastic_index_name+'/_doc/1/_source'
    response = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code != 200):
        return False
    print(response.json()['is_configured'])
    return response.json()['is_configured']

# Function - Create ingest pipeline
def create_ingest_pipeline():
    request_suffix = '/_ingest/pipeline/audit-trails-pipeline'
    data_file = open('include/elasticsearch/pipeline.json')
    data_json = json.load(data_file)
    data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Ingest pipeline has been created successfully.')

# Function - Create an index with mapping
def create_index_with_map():
    request_suffix = '/audit-trails-index'
    data_file = open('include/elasticsearch/mapping.json')
    data_json = json.load(data_file)
    data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index with mapping has been created successfully.')

# Function - Refresh index
def refresh_index():
    request_suffix = '/'+elastic_index_name+'/_refresh'
    response = requests.post(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    print('Index has been refreshed.')

# Function - Preconfigure Kibana
def configure_kibana():
    # Index pattern
    data_file = {
        'file': open('include/kibana/index_pattern.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Filters
    data_file = {
        'file': open('include/kibana/filters.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Search
    data_file = {
        'file': open('include/kibana/search.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Dashboard
    data_file = {
        'file': open('include/kibana/dashboard.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Detections (not stable, throws error 400 from time to time)
    data_file = {
        'file': open('include/kibana/detections.ndjson', 'rb')
    }
    request_suffix = '/api/detection_engine/rules/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)
    print(response.text)

# Function - Download JSON logs to local folder
def download_s3_folder(s3_bucket, s3_folder, local_folder=None):
    bucket = s3.Bucket(s3_bucket)
    if not os.path.exists(local_folder):
            os.makedirs(local_folder)
    for obj in bucket.objects.filter(Prefix=s3_folder):
        target = obj.key if local_folder is None \
            else os.path.join(local_folder, os.path.relpath(obj.key, s3_folder))
        if not os.path.exists(local_folder):
            os.makedirs(local_folder)
        if obj.key[-1] == '/':
            continue
        # Downloading JSON logs in a flat-structured way
        bucket.download_file(obj.key, local_folder+'/'+target.rsplit('/')[-1])
    # Deleting files in a bucket
    for obj in bucket.objects.filter(Prefix=s3_folder):
        if(obj.key != s3_folder+'/'):
            bucket.delete_objects(
                Delete={
                    'Objects': [
                        {
                            'Key': obj.key
                        },
                    ]
                }
            )
    print('JSON download has completed successfully.')

# Function - Upload logs to ElasticSearch
def upload_docs_bulk():
    request_suffix = '/'+elastic_index_name+'/_bulk?pipeline=audit-trails-pipeline'
    
    for f in os.listdir(s3_local):
        if f.endswith(".json"):
            with open(s3_local+"/"+f, "r") as read_file:
                data = json.load(read_file)
            result = [json.dumps(record) for record in data]
            with open(s3_local+'/nd-temp.json', 'w') as obj:
                for i in result:
                    obj.write('{"index":{}}\n')
                    obj.write(i+'\n')
            
            data_file = open(s3_local+'/nd-temp.json', 'rb').read()
            requests.post(elastic_server+request_suffix, data=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/x-ndjson"})
            os.remove(s3_local+"/"+f)
    #os.remove(s3_local+'/nd-temp.json')
    #os.rmdir(s3_local)
    print('Bulk upload has completed successfully.')
    refresh_index()

# Process - Upload data
def upload_logs():
    if(get_config_index_state()):
        print("Configuration already exists.")
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk()
        print("Data has been uploaded successfully.")
    else:
        create_index_with_map()
        create_ingest_pipeline()
        configure_kibana()
        create_config_index()
        print("Configuration has been completed successfully.")
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk()
        print("Data has been uploaded successfully.")

### MAIN CONTROL PANEL

upload_logs()
# get_config_index_state()
# update_config_index_state()
# get_config_index_state()
# upload_docs_bulk()
# download_s3_folder(s3_bucket, s3_folder, s3_local)
# upload_docs_bulk()
# refresh_index()
time.sleep(sleep_time)