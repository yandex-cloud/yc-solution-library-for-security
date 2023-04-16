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
    request_suffix = kms_key_id+':decrypt'
    request_json_data = {'ciphertext': secret}
    response = requests.post('https://kms.yandex/kms/v1/keys/'+request_suffix, data=json.dumps(request_json_data), headers={"Accept":"application/json", "Authorization": "Bearer "+token})
    b64_data = response.json().get('plaintext')
    return base64.b64decode(b64_data).decode()

# Configuration - Keys
kms_key_id              = os.environ['KMS_KEY_ID']
s3_key_encr             = os.environ['S3_KEY_ENCR']
s3_secret_encr          = os.environ['S3_SECRET_ENCR']


# Configuration - Setting up variables for S3
s3_key              = decrypt_secret_kms(s3_key_encr)
s3_secret           = decrypt_secret_kms(s3_secret_encr)

# Configuration - Sleep time
if(os.getenv('SLEEP_TIME') is not None):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

print('s3-key' + ' ' + s3_key)
print('s3-secret' + ' ' + s3_secret)


print("Sleep -- STARTED")
time.sleep(sleep_time)