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

    for page in page_iterator:
        contents = page.get('Contents', [])
        if contents:
            # Get the first file (top file in current listing)
            obj = contents[0]
            key = obj['Key']
            local_path = os.path.join(tmp_dir, os.path.basename(key))

            # Download the file to the temporary directory
            s3.download_file(logs_bucket_name, key, local_path)
            downloaded_files.append(local_path)
        break  # Only process the first page and first file

    return {
        "downloaded_files": downloaded_files,
        "total_files": len(downloaded_files)
    }
