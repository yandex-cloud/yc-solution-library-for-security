import json

import os
import sys
import uuid
import boto3
import string
import random

from datetime import datetime


def get_random_alphanumeric_string(length):
    letters_and_digits = string.ascii_letters + string.digits
    result_str = ''.join((random.choice(letters_and_digits) for i in range(length)))
    return result_str


client = boto3.client(
       service_name='s3',
       endpoint_url='https://storage.yandexcloud.net',
       region_name='ru-central1'
    )

def handler(event, context):

    for log_data in event['messages']:

        full_log = []
        for log_entry in  log_data['details']['messages']:
            kubernetes_log = json.loads(log_entry['message'])
            full_log.append(json.dumps(kubernetes_log))

        bucket_name = os.environ.get('BUCKET_NAME')
       # object_key = os.environ.get('LOG_PREFIX')+'/'+datetime.now().strftime('%Y-%m-%d-%H:%M:%S')+'-'+get_random_alphanumeric_string(5)
        object_key = 'AUDIT/'+os.environ.get('CLUSTER_ID')+'/'+datetime.now().strftime('%Y-%m-%d-%H:%M:%S')+'-'+get_random_alphanumeric_string(5)
        object_value = '\n'.join(full_log)
        client.put_object(Bucket=bucket_name, Key=object_key, Body=object_value, StorageClass='COLD')
        print(object_value)
