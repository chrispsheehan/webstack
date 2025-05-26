import os
import boto3
import json
from datetime import datetime

def handler(event, context):
    # Initialize clients
    ce = boto3.client('ce')
    s3 = boto3.client('s3')

    # Define the cost filter
    cost_filter = {
        "And": [
            {
                "Tags": {
                    "Key": "Environment",
                    "Values": ["dev"],
                    "MatchOptions": ["EQUALS"]
                }
            },
            {
                "Tags": {
                    "Key": "Project",
                    "Values": ["chrispsheehan-webstack"],
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

    # Save to S3
    bucket_name = os.environ.get("REPORT_BUCKET")
    if not bucket_name:
        raise ValueError("❌ COST_REPORT_BUCKET environment variable is not set.")
    key_name = f"cost-explorer/reports/{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.json"

    s3.put_object(
        Bucket=bucket_name,
        Key=key_name,
        Body=response_json,
        ContentType='application/json'
    )

    print(f"✅ Report saved to s3://{bucket_name}/{key_name}")
    return {"s3_path": f"s3://{bucket_name}/{key_name}"}
