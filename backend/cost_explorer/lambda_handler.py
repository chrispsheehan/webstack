import os
import boto3
import json
from datetime import datetime

def handler(event, context):
    ce = boto3.client('ce')
    s3 = boto3.client('s3')

    bucket_name = os.environ.get("REPORT_BUCKET")
    if not bucket_name:
        raise ValueError("❌ COST_REPORT_BUCKET environment variable is not set.")

    project_name = os.environ.get("PROJECT_NAME")
    if not bucket_name:
        raise ValueError("❌ PROJECT_NAME environment variable is not set.")
    
    environment_name = os.environ.get("ENVIRONMENT_NAME")
    if not bucket_name:
        raise ValueError("❌ ENVIRONMENT_NAME environment variable is not set.")

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

    # Define time period
    time_period = {
        'Start': '2025-04-01',
        'End': '2025-04-30'
    }

    metrics = ['BlendedCost', 'UnblendedCost']

    # Get cost and usage
    response = ce.get_cost_and_usage(
        TimePeriod=time_period,
        Granularity='MONTHLY',
        Metrics=metrics,
        Filter=cost_filter
    )

    # Convert response to JSON
    response_json = json.dumps(response, indent=2)

    key_name = f"cost-explorer/reports/{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.json"

    s3.put_object(
        Bucket=bucket_name,
        Key=key_name,
        Body=response_json,
        ContentType='application/json'
    )

    print(f"✅ Report saved to s3://{bucket_name}/{key_name}")
    return {"s3_path": f"s3://{bucket_name}/{key_name}"}
