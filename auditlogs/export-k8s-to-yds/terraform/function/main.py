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


# client = boto3.client(
#        service_name='s3',
#        endpoint_url='https://storage.yandexcloud.net',
#        region_name='ru-central1'
#     )

client = boto3.client(
       'kinesis',
       endpoint_url='https://yds.serverless.yandexcloud.net',
       region_name='ru-central1'
    )

def handler(event, context):
    yds_name = os.environ.get('YDS_NAME')
    yds_id = os.environ.get('YDS_ID')
    yds_ydb_id = os.environ.get('YDS_YDB_ID')
    folder_name = os.environ.get('CLOUD_ID')
    push_to_kinesis = []
    for log_data in event['messages']:
        for log_entry in  log_data['details']['messages']:
            push_to_kinesis.append({'Data': log_entry['message'],'PartitionKey': str(get_random_alphanumeric_string(5))} )
            response = client.put_records(StreamName="/ru-central1/{folder}/{database}/{stream}".format(folder=folder_name, database=yds_ydb_id, stream=yds_name), Records=push_to_kinesis)
    num_of_records = len(push_to_kinesis)
    print(f'Records count - {num_of_records}')
    print(f'Response from YDS - {response}')
