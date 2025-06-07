import os
import boto3
import gzip
import shutil
import re
from collections import defaultdict

logs_bucket_name = os.environ["S3_LOGS_BUCKET"]
out_path = os.environ["LOG_PROCESSOR_OUT"]

if not logs_bucket_name:
    raise ValueError("S3_LOGS_BUCKET must be set as an environment variable")

if not out_path:
    raise ValueError("LOG_PROCESSOR_OUT must be set as an environment variable")

unzip_dir = os.path.join(out_path, "unzip")

s3 = boto3.client('s3')


def download_logs(bucket_name: str, destination_dir: str, max_files: int = None):
    """Downloads CloudFront log files from S3 to local directory."""
    os.makedirs(destination_dir, exist_ok=True)

    print(f"📥 Starting download from bucket: {bucket_name}")
    downloaded_files = []

    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket_name)

    for page in page_iterator:
        contents = page.get('Contents', [])
        for obj in contents:
            key = obj['Key']
            local_path = os.path.join(destination_dir, os.path.basename(key))

            s3.download_file(bucket_name, key, local_path)
            downloaded_files.append(local_path)

            if max_files and len(downloaded_files) >= max_files:
                return downloaded_files

    print(f"✅ Download complete: {len(downloaded_files)} files")
    return downloaded_files


def unzip_logs(gz_files: list[str], destination_dir: str):
    """Unzips .gz log files to a subdirectory under the given destination."""
    os.makedirs(destination_dir, exist_ok=True)

    print(f"📂 Starting unzip of {len(gz_files)} files...")
    unzipped_files = []

    for gz_file in gz_files:
        filename = os.path.basename(gz_file).replace('.gz', '')
        output_path = os.path.join(destination_dir, filename)

        with gzip.open(gz_file, 'rb') as f_in, open(output_path, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

        unzipped_files.append(output_path)

    print(f"✅ Unzip complete: {len(unzipped_files)} files")
    return unzipped_files


# Regex pattern for bots (simple heuristic)
BOT_PATTERN = re.compile(r"bot|spider|crawl|slurp|fetch|python-requests|curl|wget|monitor", re.I)

def collate_unique_visitors_filtered(unzipped_files: list[str]) -> dict:
    """
    Parses unzipped CloudFront logs, collates unique visitors per day,
    ignoring visits from bots (based on User-Agent).
    """
    visitors_by_date = defaultdict(set)

    print(f"📊 Starting log collation across {len(unzipped_files)} files...")

    for file_path in unzipped_files:
        with open(file_path, 'r') as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\t')
                if len(parts) < 12:
                    continue

                date = parts[0]
                visitor_id = parts[4]
                user_agent = parts[11]

                if BOT_PATTERN.search(user_agent):
                    continue  # Skip bots

                visitors_by_date[date].add(visitor_id)

    result = {date: len(visitors) for date, visitors in visitors_by_date.items()}
    print(f"✅ Collation complete. Days found: {len(result)}")
    return result


def logs_report():
    downloaded_files = download_logs(logs_bucket_name, out_path)
    unzipped_files = unzip_logs(downloaded_files, unzip_dir)
    unique_visitors = collate_unique_visitors_filtered(unzipped_files)
    print(f"\n📈 Unique visitors summary:\n{unique_visitors}")
    return unique_visitors
