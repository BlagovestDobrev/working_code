import logging
import boto3
from botocore.exceptions import ClientError
from datetime import datetime


def lambda_handler(event, context):
    current_time=datetime.now().strftime("%d-%m-%Y-%H-%M-%S")

    s3_client = boto3.resource('s3')

    """buckets list"""
    buckets=["qa-firstname-lastname-stormreply-platform-challenge-0708","staging-firstname-lastname-stormreply-platform-challenge-0708"]

    for bucket_name in buckets:
        try:
            """Generating file and uploading it to a bucket"""
            content="This is for bucket: " + bucket_name
            s3_client.Object(bucket_name, current_time+'_file.txt').put(Body=content)
                
        except ClientError as e:
            logging.error(e)
            return False
    
    for bucket in s3_client.buckets.all():
        print(bucket.name)

    return True