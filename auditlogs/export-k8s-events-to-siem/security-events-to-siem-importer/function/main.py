import boto3
import json

import os
import sys
import uuid


client = boto3.client(
        service_name='sqs',
        endpoint_url='https://message-queue.api.cloud.yandex.net',
        region_name='ru-central1'
    )

s3_client = boto3.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net',
    region_name='ru-central1',
)


def handler(event, context):
    queue_url = os.environ.get('YMQ_URL')
        

    for message in event['messages']:
        if os.environ.get('AUDIT_LOG_PREFIX') is not None and  message['details']['object_id'].startswith(os.environ.get('AUDIT_LOG_PREFIX')):
            log_type = 'AUDIT'
        elif os.environ.get('FALCO_LOG_PREFIX') is not None and message['details']['object_id'].startswith(os.environ.get('FALCO_LOG_PREFIX')):
            log_type = 'FALCO'
        else: 
            log_type = 'UNKNOWN'
        #print(message['details']['object_id'])
        metadata_list = message['details']['object_id'].split("/")
        #print(metadata_list)
        data = {
            'log_type': log_type,
            'bucket_id': message['details']['bucket_id'],
            'object_id': message['details']['object_id'],
            'cloud_id': metadata_list[1],
            'folder_id': metadata_list[2],
            'cluster_id': metadata_list[3],
            'cluster_url': "https://console.cloud.yandex.ru/folders/"+metadata_list[2]+"/managed-kubernetes/cluster/"+ metadata_list[3]
         }
        print(data)
        log_obj = s3_client.get_object(Bucket=message['details']['bucket_id'], Key=message['details']['object_id'])
        file_content = log_obj['Body'].read()
        #json_content = json.loads(file_content)
        print(file_content)
        client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(data),
            MessageGroupId = "%s\%s" % (message['details']['bucket_id'],log_type)
        )
        print('Successfully sent  message to queue')

    