import boto3
import os
import time


# Configuration - Setting up variables for S3
s3_bucket           = os.environ['S3_BUCKET']
s3_folder           = "AUDIT"
s3_key              = os.environ['S3_KEY']
s3_secret           = os.environ['S3_SECRET']
sqs_name            = os.environ['SQS_NAME']


# State - Setting up S3 client
sqs = boto3.client(
    service_name            = 'sqs',
    endpoint_url            = 'https://message-queue.api.cloud.yandex.net',
    region_name             = 'ru-central1',
    aws_access_key_id       = s3_key,
    aws_secret_access_key   = s3_secret 
)

s3 = boto3.resource('s3',
    endpoint_url            = 'https://storage.yandexcloud.net',
    aws_access_key_id       = s3_key,
    aws_secret_access_key   = s3_secret 
)

sqs_url = (sqs.get_queue_url(QueueName=sqs_name))['QueueUrl']


# Configuration - Sleep time
if(os.getenv('SLEEP_TIME') is not None):
    sleep_time = int(os.environ['SLEEP_TIME'])
else:
    sleep_time = 240

# Functions
def send_ymq_msg(message_body):
    sqs.send_message(
        QueueUrl=sqs_url,
        MessageBody=message_body
    )

def process_s3_folder(bucket, folder):
    count = 0
    b = s3.Bucket(bucket)
    for obj in b.objects.filter(Prefix=folder):
        if obj.key[-1] == '/':
            continue
        send_ymq_msg(obj.key)
        count += 1
    print(f"{count} files pushed to queue")


# Main
process_s3_folder(s3_bucket, s3_folder)
print("Sleep -- STARTED")
time.sleep(sleep_time)