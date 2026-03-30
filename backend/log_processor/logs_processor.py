import gzip
import logging
import os
import re
from collections import defaultdict
from datetime import datetime, timezone

import boto3

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s %(message)s")


def _require_env(name: str) -> str:
    value = os.environ.get(name, "")
    if not value:
        raise ValueError(f"{name} environment variable must be set")
    return value


logs_bucket_name = _require_env("S3_LOGS_BUCKET")
out_path = os.environ.get("LOG_PROCESSOR_OUT", "/tmp")
logs_prefix = os.environ.get("S3_LOGS_PREFIX", "")

s3 = boto3.client("s3")

BOT_PATTERN = re.compile(
    r"bot|spider|crawl|slurp|fetch|python-requests|curl|wget|monitor",
    re.I,
)


def download_logs(bucket_name: str, prefix: str, destination_dir: str) -> list[str]:
    """Download CloudFront log .gz files from S3 to a local directory."""
    os.makedirs(destination_dir, exist_ok=True)
    downloaded_files = []

    logger.info("Downloading logs from s3://%s/%s", bucket_name, prefix)

    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            local_path = os.path.join(destination_dir, os.path.basename(key))
            s3.download_file(bucket_name, key, local_path)
            downloaded_files.append(local_path)

    logger.info("Downloaded %d log files", len(downloaded_files))
    return downloaded_files


def parse_gz_file_stream(file_path: str, visitor_tracker: defaultdict) -> None:
    """Parse a single .gz CloudFront log file and update visitor tracker.

    CloudFront log fields (tab-separated):
      0: date, 1: time, 2: x-edge-location, 3: sc-bytes,
      4: c-ip, 5: cs-method, 6: cs(Host), 7: cs-uri-stem,
      8: sc-status, 9: cs(Referer), 10: cs(User-Agent), 11: cs-uri-query
    """
    with gzip.open(file_path, "rt") as f:
        for line in f:
            if line.startswith("#"):
                continue
            parts = line.strip().split("\t")
            if len(parts) < 11:
                continue

            date = parts[0]
            visitor_id = parts[4]   # c-ip (client IP)
            user_agent = parts[10]  # cs(User-Agent)

            if BOT_PATTERN.search(user_agent):
                continue

            visitor_tracker[date].add(visitor_id)


def logs_report() -> dict:
    """Download CloudFront logs, parse them, and return visitor metrics.

    'daily-visits' reflects the most recently completed day (second-to-last
    in sorted order) because today's log files may still be incomplete at
    the time this runs.
    """
    downloaded_files = download_logs(logs_bucket_name, logs_prefix, out_path)
    visitor_tracker: defaultdict[str, set] = defaultdict(set)

    logger.info("Parsing %d log files", len(downloaded_files))

    for gz_file in downloaded_files:
        try:
            parse_gz_file_stream(gz_file, visitor_tracker)
        except Exception as exc:
            logger.warning("Skipping unreadable log file %s: %s", gz_file, exc)
        finally:
            try:
                os.remove(gz_file)
            except OSError as exc:
                logger.warning("Could not remove temp file %s: %s", gz_file, exc)

    today = datetime.now(timezone.utc).date()

    if not visitor_tracker:
        logger.warning("No visit data found")
        return {
            "daily-visits": 0,
            "total-visits": 0,
            "range": 0,
            "last-date": str(today),
            "generated-at": str(today),
        }

    daily_counts = {date: len(visitors) for date, visitors in visitor_tracker.items()}
    sorted_dates = sorted(daily_counts.keys())
    range_days = len(sorted_dates)
    total_visits = sum(daily_counts.values())

    # Use second-to-last day as "yesterday" since today's logs may be incomplete
    daily_visits = daily_counts[sorted_dates[-2]] if range_days >= 2 else daily_counts[sorted_dates[-1]]

    result = {
        "daily-visits": daily_visits,
        "total-visits": total_visits,
        "range": range_days,
        "last-date": sorted_dates[-1],
        "generated-at": str(today),
    }

    logger.info("Visitor metrics: %s", result)
    return result
