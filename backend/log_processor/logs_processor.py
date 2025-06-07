import os
import boto3
import gzip
import re
from collections import defaultdict

# Environment variables
logs_bucket_name = os.environ["S3_LOGS_BUCKET"]
out_path = os.environ.get("LOG_PROCESSOR_OUT", "/tmp")

# Safety checks
if not logs_bucket_name:
    raise ValueError("S3_LOGS_BUCKET must be set")
if not out_path:
    raise ValueError("LOG_PROCESSOR_OUT must be set")

# AWS S3 client
s3 = boto3.client('s3')

# Simple bot pattern
BOT_PATTERN = re.compile(r"bot|spider|crawl|slurp|fetch|python-requests|curl|wget|monitor", re.I)


def download_logs(bucket_name: str, destination_dir: str, max_files: int = None) -> list[str]:
    """Download CloudFront log .gz files to a local directory."""
    os.makedirs(destination_dir, exist_ok=True)
    downloaded_files = []

    print(f"📥 Starting download from bucket: {bucket_name}")

    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket_name)

    for page in page_iterator:
        for obj in page.get('Contents', []):
            key = obj['Key']
            local_path = os.path.join(destination_dir, os.path.basename(key))

            s3.download_file(bucket_name, key, local_path)
            downloaded_files.append(local_path)

            if max_files and len(downloaded_files) >= max_files:
                print(f"✅ Downloaded {len(downloaded_files)} files (max limit reached)")
                return downloaded_files

    print(f"✅ Download complete: {len(downloaded_files)} files")
    return downloaded_files


def parse_gz_file_stream(file_path: str, visitor_tracker: defaultdict):
    """Parse a single .gz log file and update visitor tracker."""
    with gzip.open(file_path, 'rt') as f:  # 'rt' = read text mode
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

            visitor_tracker[date].add(visitor_id)


def logs_report(max_files: int = None):
    """Main function: download logs, parse, and report unique visitors."""
    downloaded_files = download_logs(logs_bucket_name, out_path, max_files=max_files)
    visitor_tracker = defaultdict(set)

    print(f"📊 Starting log collation...")

    for gz_file in downloaded_files:
        parse_gz_file_stream(gz_file, visitor_tracker)
        os.remove(gz_file)  # Clean up

    result = {date: len(visitors) for date, visitors in visitor_tracker.items()}
    print(f"\n📈 Unique visitors summary:\n{result}")
    return result
