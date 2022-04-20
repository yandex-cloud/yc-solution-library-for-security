import boto3
import json
import os

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
    folder_id = os.environ.get('FOLDER_ID')
    cluster_id = os.environ.get('CLUSTER_ID')


    for message in event['messages']:
        if os.environ.get('AUDIT_LOG_PREFIX') is not None and  message['details']['object_id'].startswith(os.environ.get('AUDIT_LOG_PREFIX')):
            log_type = 'AUDIT'
        elif os.environ.get('FALCO_LOG_PREFIX') is not None and message['details']['object_id'].startswith(os.environ.get('FALCO_LOG_PREFIX')):
            log_type = 'FALCO'
        elif os.environ.get('KYVERNO_LOG_PREFIX') is not None and message['details']['object_id'].startswith(os.environ.get('KYVERNO_LOG_PREFIX')):
            log_type = 'KYVERNO'
        else:
            log_type = 'UNKNOWN'
        metadata_list = message['details']['object_id'].split("/")
        data = {
            'log_type': log_type,
            'bucket_id': message['details']['bucket_id'],
            'object_id': message['details']['object_id'],
            'cloud_id': os.environ.get('CLOUD_ID'),
            'folder_id': os.environ.get('FOLDER_ID'),
            'cluster_id': os.environ.get('CLUSTER_ID'),
            'cluster_url': "https://console.cloud.yandex.ru/folders/" + str(folder_id) + "/managed-kubernetes/cluster/" + str(cluster_id)
         }
        print(data)
        log_obj = s3_client.get_object(Bucket=message['details']['bucket_id'], Key=message['details']['object_id'])
        file_content = log_obj['Body'].read()
        print(file_content)
        client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(data),
            MessageGroupId = "%s\%s" % (message['details']['bucket_id'],log_type)
        )
        print('Successfully sent  message to queue')
