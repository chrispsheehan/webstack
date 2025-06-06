import os
import boto3

logs_bucket_name = os.environ["S3_LOGS_BUCKET"]
out_path = "/Users/chrissheehan/git/chrispsheehan/webstack/backend/tmp"

s3 = boto3.client('s3')

def logs_report():
    tmp_dir = out_path
    downloaded_files = []

    # List all objects in the bucket
    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=logs_bucket_name)

    first_file_downloaded = False

    for page in page_iterator:
        contents = page.get('Contents', [])
        for i, obj in enumerate(contents):
            key = obj['Key']
            local_path = os.path.join(tmp_dir, os.path.basename(key))

            if not first_file_downloaded:
                s3.download_file(logs_bucket_name, key, local_path)
                downloaded_files.append(local_path)
                first_file_downloaded = True
                print(f"Downloaded top file: {key}")
            else:
                s3.download_file(logs_bucket_name, key, local_path)
                downloaded_files.append(local_path)
                print(f"Downloaded: {key}")

    return {
        "downloaded_files": downloaded_files, # this it array of ['/Users/chrissheehan/git/chrispsheehan/webstack/backend/tmp/E2O3LP7E8DA6KI.2025-05-22-00.e97db493.gz']
        "total_files": len(downloaded_files)
    }
