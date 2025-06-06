import os
import boto3
from datetime import datetime, timedelta

ce = boto3.client("ce")

logs_bucket_name = os.environ["S3_LOGS_BUCKET"]

def logs_report(project_name: str, environment_name: str):

    return {
        "this": 1
    }
