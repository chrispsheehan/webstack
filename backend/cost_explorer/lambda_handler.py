import boto3
import json

def lambda_handler(event, context):
    # Initialize the Cost Explorer client
    ce = boto3.client('ce')

    # Define the cost filter directly in code
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

    # Define the time period
    time_period = {
        'Start': '2025-04-01',
        'End': '2025-04-30'
    }

    # Define the metrics
    metrics = ['BlendedCost', 'UnblendedCost']

    # Make the API call
    response = ce.get_cost_and_usage(
        TimePeriod=time_period,
        Granularity='MONTHLY',
        Metrics=metrics,
        Filter=cost_filter
    )

    # Output the response to the console
    print(json.dumps(response, indent=2))

    return response
