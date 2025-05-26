import os
import boto3
import json
from datetime import datetime, timedelta

def handler(event, context):
    ce = boto3.client('ce')
    s3 = boto3.client('s3')

    # Get env vars
    bucket_name = os.environ.get("REPORT_BUCKET")
    if not bucket_name:
        raise ValueError("❌ REPORT_BUCKET environment variable is not set.")

    project_name = os.environ.get("PROJECT_NAME")
    if not project_name:
        raise ValueError("❌ PROJECT_NAME environment variable is not set.")
    
    environment_name = os.environ.get("ENVIRONMENT_NAME")
    if not environment_name:
        raise ValueError("❌ ENVIRONMENT_NAME environment variable is not set.")

    # Build cost filter
    cost_filter = {
        "And": [
            {
                "Tags": {
                    "Key": "Environment",
                    "Values": [environment_name],
                    "MatchOptions": ["EQUALS"]
                }
            },
            {
                "Tags": {
                    "Key": "Project",
                    "Values": [project_name],
                    "MatchOptions": ["EQUALS"]
                }
            }
        ]
    }

    # Dates
    today = datetime.utcnow().date()
    yesterday = today - timedelta(days=1)
    month_start = today.replace(day=1)
    
    # Format for Cost Explorer
    metrics = ['BlendedCost', 'UnblendedCost']

    # 1. Daily cost (for yesterday)
    daily_resp = ce.get_cost_and_usage(
        TimePeriod={
            'Start': str(yesterday),
            'End': str(today)
        },
        Granularity='DAILY',
        Metrics=metrics,
        Filter=cost_filter
    )

    # 2. Month-to-date cost (Start of month to today)
    monthly_resp = ce.get_cost_and_usage(
        TimePeriod={
            'Start': str(month_start),
            'End': str(today)
        },
        Granularity='MONTHLY',
        Metrics=metrics,
        Filter=cost_filter
    )

    # Combine and format response
    combined = {
        "date": str(yesterday),
        "daily": daily_resp['ResultsByTime'][0],  # single day
        "month_to_date": monthly_resp['ResultsByTime'][0]
    }

    # Save to S3 with the date as the key
    key_name = f"cost-explorer/reports/{yesterday.strftime('%Y-%m-%d')}.json"

    s3.put_object(
        Bucket=bucket_name,
        Key=key_name,
        Body=json.dumps(combined, indent=2),
        ContentType='application/json'
    )

    print(f"✅ Cost report saved to s3://{bucket_name}/{key_name}")
    return {"s3_path": f"s3://{bucket_name}/{key_name}"}
