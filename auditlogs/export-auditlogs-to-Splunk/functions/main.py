import requests
import json
import os
import boto3
import time
import base64

# Function - Get token
def get_token():
    response = requests.get('http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token', headers={"Metadata-Flavor":"Google"})
    return response.json().get('access_token')

# Function - Decrypt data with KMS key
def decrypt_secret_kms(secret):
    token = get_token()
    request_suffix = f"{kms_key_id}:decrypt"
    request_json_data = {'ciphertext': secret}
    response = requests.post('https://kms.yandex/kms/v1/keys/'+request_suffix, data=json.dumps(request_json_data), headers={"Accept":"application/json", "Authorization": "Bearer "+token})
    b64_data = response.json().get('plaintext')
    return base64.b64decode(b64_data).decode()


# Configuration - Keys
kms_key_id              = os.environ['KMS_KEY_ID']
splunk_token    = os.environ['SPLUNK_TOKEN_ENCR']
s3_key_encr             = os.environ['S3_KEY_ENCR']
s3_secret_encr          = os.environ['S3_SECRET_ENCR']

# Configuration - Setting up variables for ElasticSearch
splunk_server      = os.environ['SPLUNK_SERVER']
splunk_auth_pw     = decrypt_secret_kms(splunk_token)

# Configuration - Setting up variables for S3
s3_key              = decrypt_secret_kms(s3_key_encr)
s3_secret           = decrypt_secret_kms(s3_secret_encr)
s3_bucket           = os.environ['S3_BUCKET']
s3_folder           = os.environ['S3_FOLDER']
s3_local            = '/tmp/s3'

# Configuration - Sleep time
if(os.getenv('SLEEP_TIME') is not None):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

# State - Setting up S3 client
s3 = boto3.resource('s3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id = s3_key,
    aws_secret_access_key = s3_secret 
)



# Function - Download JSON logs to local folder
def download_s3_folder(s3_bucket, s3_folder, local_folder=None):
    print('JSON download -- STARTED')
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
    print('JSON download -- COMPLETE')

# Function - Clean up S3 folder
def delete_objects_s3(s3_bucket, s3_folder):
    bucket = s3.Bucket(s3_bucket)
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
    print('S3 bucket -- EMPTIED')

# Function - Upload logs to ElasticSearch
def upload_docs_bulk(s3_bucket, s3_folder):
    print('JSON upload -- STARTED')
    request_suffix = "/services/collector/event"
    error_count = 0

    for f in os.listdir(s3_local):
        if f.endswith(".json"):
            with open(f"{s3_local}/{f}", "r") as read_file:
                data = json.load(read_file)
            result = [json.dumps(record) for record in data]
            
            with open(f"{s3_local}/nd-temp.json", 'w') as obj:
                for i in result:
                    obj.write('{\n')
                    obj.write('"time":'+' '+ str(time.time()) + ','+ '\n')  
                    obj.write('"event":'+ ' '+i+'\n') 
                    obj.write('}\n')
                    obj.write('\n')
                
            data_file = open(f"{s3_local}/nd-temp.json", 'rb').read()
            response = requests.post(splunk_server+request_suffix, data=data_file, verify=False, headers={"Authorization":"Splunk "+ splunk_auth_pw})
            os.remove(s3_local+"/"+f)
            if(response.status_code != 200):
                error_count += 1
                print(response.text)
    if(os.path.exists(f"{s3_local}/nd-temp.json")):
        os.remove(f"{s3_local}/nd-temp.json")
    print(f"JSON upload -- COMPLETE -- {error_count} ERRORS")
    if(error_count == 0):
        delete_objects_s3(s3_bucket, s3_folder)
    refresh_index()

# Process - Upload data
def upload_logs():
    if(get_config_index_state()):
        print("Config index -- EXISTS")
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk(s3_bucket, s3_folder)
    else:
        create_index_with_map()
        create_ingest_pipeline()
        configure_kibana()
        create_config_index()
        download_s3_folder(s3_bucket, s3_folder, s3_local)
        upload_docs_bulk(s3_bucket, s3_folder)

### MAIN CONTROL PANEL

upload_logs()
print("Sleep -- STARTED")
time.sleep(sleep_time)