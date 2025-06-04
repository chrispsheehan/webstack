import os
import sys
import boto3
import json
from datetime import datetime, timedelta

ce = boto3.client("ce")
s3 = boto3.client("s3")


def handler(event, context):
    try:
        # ─── ENV VARS ────────────────────────────────────────────────────────────
        bucket_name = os.environ["REPORT_BUCKET"]
        project_name = os.environ["PROJECT_NAME"]
        environment_name = os.environ["ENVIRONMENT_NAME"]

        # ─── COST EXPLORER FILTER ───────────────────────────────────────────────
        cost_filter = {
            "And": [
                {
                    "Tags": {
                        "Key": "Environment",
                        "Values": [environment_name],
                        "MatchOptions": ["EQUALS"],
                    }
                },
                {
                    "Tags": {
                        "Key": "Project",
                        "Values": [project_name],
                        "MatchOptions": ["EQUALS"],
                    }
                },
            ]
        }

        metrics = ["BlendedCost", "UnblendedCost"]

        # ─── DATE RANGES ────────────────────────────────────────────────────────
        today = datetime.utcnow().date()
        yesterday = today - timedelta(days=1)
        month_start = today.replace(day=1)

        first_day_this_month = today.replace(day=1)
        last_day_prev_month = first_day_this_month - timedelta(days=1)
        first_day_prev_month = last_day_prev_month.replace(day=1)

        # ─── CE QUERIES ─────────────────────────────────────────────────────────
        daily_resp = ce.get_cost_and_usage(
            TimePeriod={"Start": str(yesterday), "End": str(today)},
            Granularity="DAILY",
            Metrics=metrics,
            Filter=cost_filter,
        )

        if month_start < today:
            # Safe to query
            monthly_resp = ce.get_cost_and_usage(
                TimePeriod={
                    'Start': str(month_start),
                    'End': str(today)
                },
                Granularity='MONTHLY',
                Metrics=metrics,
                Filter=cost_filter
            )
        else:
            # First day of month — nothing to report yet
            monthly_resp = {"ResultsByTime": [{"Total": {m: {"Amount": "0", "Unit": "USD"} for m in metrics}}]}

        prev_month_resp = ce.get_cost_and_usage(
            TimePeriod={
                "Start": str(first_day_prev_month),
                "End": str(last_day_prev_month + timedelta(days=1)),  # CE end is exclusive
            },
            Granularity="MONTHLY",
            Metrics=metrics,
            Filter=cost_filter,
        )

        combined = {
            "date": str(yesterday),
            "daily": daily_resp["ResultsByTime"][0],
            "month_to_date": monthly_resp["ResultsByTime"][0],
            "previous_month": {
                "start": str(first_day_prev_month),
                "end": str(last_day_prev_month),
                "data": prev_month_resp["ResultsByTime"][0],
            },
        }

        key_name = f"data/cost-explorer/data.json"

        s3.put_object(
            Bucket=bucket_name,
            Key=key_name,
            Body=json.dumps(combined, indent=2),
            ContentType="application/json",
        )

        print(f"✅ Cost report saved to s3://{bucket_name}/{key_name}")
        return {"statusCode": 200, "body": json.dumps({"s3_path": f"s3://{bucket_name}/{key_name}"})}

    # ─── ERROR HANDLING ────────────────────────────────────────────────────────
    except Exception as exc:
        error_msg = f"❌ Cost-report Lambda failed: {exc}"
        print(error_msg, file=sys.stderr)

        # Return 500 JSON for API Gateway / test invocations
        return {"statusCode": 500, "body": json.dumps({"error": str(exc)})}


# ─── Allow `python lambda_handler.py` to fail CI with a non-zero exit code ─────
if __name__ == "__main__":
    result = handler({}, None)
    if result.get("statusCode") != 200:
        sys.exit(1)
