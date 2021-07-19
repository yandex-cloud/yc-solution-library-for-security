import requests
import json
import os
import boto3

# State - Setting up variables for ElasticSearch
elastic_server = 'https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net:9200'
elastic_cert = 'auditlogs/export-auditlogs-to-ELK/include/ca.pem'
elastic_auth_user = 'admin'
elastic_auth_pw = 'elasticsearch'
elastic_index_name = 'audit-trails-index'
kibana_server = 'https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net'

# State - Setting up variables for S3
s3_key = 'qlcr3TERjc6ZBeP4Mveq'
s3_secret = 'PWkhhZy5tZYY5W3jd-gpxTQ4VuoUrvAg_dyIzTtI'
s3_bucket = 'audittrail8'
s3_folder = 'audit-logs'
s3_local = "auditlogs/export-auditlogs-to-ELK/temp"

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
            "first_run": true
        }"""
        response = requests.post(elastic_server+request_suffix, data=request_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index created successfully.')
    else:
        print('Config index already exist.')

# Function - Get config index state
def get_config_index_state():
    request_suffix = '/.state-'+elastic_index_name+'/_doc/1/_source'
    response = requests.get(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    print(response.json()['first_run'])
    return response.json()['first_run']

# Function - Switch config index state
def update_config_index_state():
    if(get_config_index_state()):
        request_suffix = '/.state-'+elastic_index_name+'/_update/1'
        request_json = """{
            "doc": {
                "first_run": false
            }
        }"""
        requests.post(elastic_server+request_suffix, data=request_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index: first_run is updated to <false>.')
    else:
        request_suffix = '/.state-'+elastic_index_name+'/_update/1'
        request_json = """{
            "doc": {
                "first_run": true
            }
        }"""
        requests.post(elastic_server+request_suffix, data=request_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"Content-Type":"application/json"})
        print('Config index: first_run is updated to <true>.')

# Function create ingest pipeline
def create_ingest_pipeline():
    request_suffix = '/_ingest/pipeline/audit-trails-pipeline'
    data_file = open('auditlogs/export-auditlogs-to-ELK/include/elasticsearch/pipeline.json')
    data_json = json.load(data_file)
    data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Ingest pipeline created successfully.')

# Function - Create an index with mapping
def create_index_with_map():
    request_suffix = '/audit-trails-index'
    data_file = open('auditlogs/export-auditlogs-to-ELK/include/elasticsearch/mapping.json')
    data_json = json.load(data_file)
    data_file.close()
    response = requests.put(elastic_server+request_suffix, json=data_json, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    if(response.status_code == 200):
        print('Index with mapping created successfully.')

# Function - Refresh index
def refresh_index():
    request_suffix = '/'+elastic_index_name+'/_refresh'
    response = requests.post(elastic_server+request_suffix, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw))
    print(response)
    print(response.text)
    print('Index refreshed.')

# Function - Preconfigure Kibana
def configure_kibana():
    # Index pattern
    data_file = {
        'file': open('auditlogs/export-auditlogs-to-ELK/include/kibana/index_pattern.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Filters
    data_file = {
        'file': open('auditlogs/export-auditlogs-to-ELK/include/kibana/filters.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Search
    data_file = {
        'file': open('auditlogs/export-auditlogs-to-ELK/include/kibana/search.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Dashboard
    data_file = {
        'file': open('auditlogs/export-auditlogs-to-ELK/include/kibana/dashboard.ndjson', 'rb')
    }
    request_suffix = '/api/saved_objects/_import'
    response = requests.post(kibana_server+request_suffix, files=data_file, verify=elastic_cert, auth=(elastic_auth_user, elastic_auth_pw), headers={"kbn-xsrf":"true"})
    print(response.status_code)

    # Detections (not stable, throws error 400 from time to time)
    data_file = {
        'file': open('auditlogs/export-auditlogs-to-ELK/include/kibana/detections.ndjson', 'rb')
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
    os.remove(s3_local+'/nd-temp.json')
    os.rmdir(s3_local)
    print('Bulk upload has completed successfully.')
    refresh_index()

# Process - Upload initial data
def upload_logs_initial():
    if(get_config_index_state()):
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk()
        update_config_index_state()
        print("Initial log upload has completed successfully.")
    else:
        print("Initial log upload has already been done. Please proceed with the log sync.")


### MAIN CONTROL PANEL
create_config_index()
create_index_with_map()
create_ingest_pipeline()
configure_kibana()
upload_logs_initial()
# get_config_index_state()
# update_config_index_state()
# get_config_index_state()
# upload_docs_bulk()
# download_s3_folder(s3_bucket, s3_folder, s3_local)
# upload_docs_bulk()
# refresh_index()

