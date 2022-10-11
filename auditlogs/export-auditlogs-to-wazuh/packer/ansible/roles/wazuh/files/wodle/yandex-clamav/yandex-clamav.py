#!/var/ossec/framework/python/bin/python3
import clamd
import boto3
import os

endpoint_url = 'https://storage.yandexcloud.net'
session = boto3.session.Session()
s3 = session.client(
    service_name='s3',
    endpoint_url=endpoint_url
)

s3_client = session.client('s3', endpoint_url=endpoint_url)


def get_buckets():
    bucket_name = []
    get_all_buckets = s3.list_buckets()
    for bucket_names in get_all_buckets['Buckets']:
        kwargs = {'Bucket': bucket_names['Name']}
        resp = s3_client.list_objects_v2(**kwargs)
        if resp['KeyCount'] < 1:
            pass
        else:
            bucket_name.append(bucket_names['Name'])
    return bucket_name


def get_matching_s3_keys(bucket_name, prefix='', suffix=''):
    """
    Generate the keys in an S3 bucket.
    :param bucket_name: Name of the S3 bucket.
    :param prefix: Only fetch keys that start with this prefix (optional).
    :param suffix: Only fetch keys that end with this suffix (optional).
    """

    kwargs = {'Bucket': bucket_name}
    if isinstance(prefix, str):
        kwargs['Prefix'] = prefix

    while True:
        resp = s3_client.list_objects_v2(**kwargs)
        for obj in resp['Contents']:

            key = obj['Key']
            if key.startswith(prefix) and key.endswith(suffix):
                s3_client.download_file(bucket_name, key, f"{base_directory}/{bucket_name}/{key.split('/')[-1]}")
                cd = clamd.ClamdUnixSocket("/var/run/clamav/clamd.ctl")
                cd.scan(f"{base_directory}/{bucket_name}/{key.split('/')[-1]}")
                os.remove(f"{base_directory}/{bucket_name}/{key.split('/')[-1]}")
        try:
            kwargs['ContinuationToken'] = resp['NextContinuationToken']
        except KeyError:
            break


if __name__ == '__main__':
    buckets = get_buckets()
    base_directory = "/tmp/scan"
    if not os.path.exists(base_directory):
        os.makedirs(base_directory)
    for bucket in buckets:
        if not os.path.exists(f"{base_directory}/{bucket}"):
            os.makedirs(f"{base_directory}/{bucket}")
        get_matching_s3_keys(bucket_name=bucket, prefix='', suffix='')
