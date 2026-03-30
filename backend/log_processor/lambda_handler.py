import json
import logging
import os
import sys

import boto3

from logs_processor import logs_report

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s %(message)s")


def _require_env(name: str) -> str:
    value = os.environ.get(name, "")
    if not value:
        raise ValueError(f"{name} environment variable must be set")
    return value


# Validate at startup so misconfiguration fails fast
report_bucket = _require_env("REPORT_BUCKET")
report_key = os.environ.get("LOG_PROCESSOR_OUTPUT_KEY", "data/log-processor/data.json")

s3 = boto3.client("s3")


def handler(event, context):
    try:
        combined = logs_report()

        s3.put_object(
            Bucket=report_bucket,
            Key=report_key,
            Body=json.dumps(combined, indent=2),
            ContentType="application/json",
        )

        logger.info("Report saved to s3://%s/%s", report_bucket, report_key)
        return {
            "statusCode": 200,
            "body": json.dumps({"s3_path": f"s3://{report_bucket}/{report_key}"}),
        }

    except Exception as exc:
        logger.error("Log processor Lambda failed: %s", exc, exc_info=True)
        return {"statusCode": 500, "body": json.dumps({"error": str(exc)})}


# Allow `python lambda_handler.py` to fail CI with a non-zero exit code
if __name__ == "__main__":
    result = handler({}, None)
    if result.get("statusCode") != 200:
        sys.exit(1)
