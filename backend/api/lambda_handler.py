import os
import json
import boto3
from datetime import datetime, timedelta, timezone

s3 = boto3.client("s3")

def handler(event, context):
    path = event.get('path', '')

    if path == '/health':
        return respond(200, {"message": "healthy"})

    if path == '/render':
        return respond(200, {"ok": False})

    if path == '/cost-report':
        try:
            return get_latest_cost_report()
        except Exception as e:
            return respond(500, {"error": str(e)})

    return respond(404, {"message": f"Unknown path: {path}"})


def get_latest_cost_report():
    bucket_name = os.environ.get("REPORT_BUCKET")
    if not bucket_name:
        raise ValueError("❌ REPORT_BUCKET environment variable is not set.")

    # Yesterday's date (since the report is saved daily)
    yesterday = datetime.now(timezone.utc).date() - timedelta(days=1)
    key = f"cost-explorer/reports/{yesterday.strftime('%Y-%m-%d')}.json"

    obj = s3.get_object(Bucket=bucket_name, Key=key)
    body = obj["Body"].read().decode("utf-8")
    data = json.loads(body)

    return respond(200, data)


def respond(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
        "headers": {"Content-Type": "application/json"}
    }
