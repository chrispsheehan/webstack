import os
import sys
import boto3
import json

from logs_processor import logs_report

s3 = boto3.client("s3")


def handler(event, context):
    try:
        combined = logs_report()

        return {"statusCode": 200, "body": json.dumps(combined)}

    # ─── ERROR HANDLING ────────────────────────────────────────────────────────
    except Exception as exc:
        error_msg = f"❌ Logs processor Lambda failed: {exc}"
        print(error_msg, file=sys.stderr)

        # Return 500 JSON for API Gateway / test invocations
        return {"statusCode": 500, "body": json.dumps({"error": str(exc)})}


# ─── Allow `python lambda_handler.py` to fail CI with a non-zero exit code ─────
if __name__ == "__main__":
    result = handler({}, None)
    if result.get("statusCode") != 200:
        sys.exit(1)
