import os
import boto3
from datetime import datetime, timedelta, timezone

ce = boto3.client("ce")


project_name = os.environ["PROJECT_NAME"]
environment_name = os.environ["ENVIRONMENT_NAME"]

if not project_name:
    raise ValueError("PROJECT_NAME must be set")
if not environment_name:
    raise ValueError("ENVIRONMENT_NAME must be set")

def generate_cost_report():
    metrics = ["BlendedCost", "UnblendedCost"]
    today = datetime.now(timezone.utc).date()
    yesterday = today - timedelta(days=1)
    day_before_yesterday = today - timedelta(days=2)
    month_start = today.replace(day=1)
    first_day_this_month = today.replace(day=1)
    last_day_prev_month = first_day_this_month - timedelta(days=1)
    first_day_prev_month = last_day_prev_month.replace(day=1)

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

    daily_resp = ce.get_cost_and_usage(
        TimePeriod={"Start": str(day_before_yesterday), "End": str(yesterday)},
        Granularity="DAILY",
        Metrics=metrics,
        Filter=cost_filter,
    )

    if month_start < today:
        monthly_resp = ce.get_cost_and_usage(
            TimePeriod={"Start": str(month_start), "End": str(today)},
            Granularity="MONTHLY",
            Metrics=metrics,
            Filter=cost_filter,
        )
    else:
        monthly_resp = {
            "ResultsByTime": [{"Total": {m: {"Amount": "0", "Unit": "USD"} for m in metrics}}]
        }

    prev_month_resp = ce.get_cost_and_usage(
        TimePeriod={
            "Start": str(first_day_prev_month),
            "End": str(last_day_prev_month + timedelta(days=1)),
        },
        Granularity="MONTHLY",
        Metrics=metrics,
        Filter=cost_filter,
    )

    result = {
        "date": str(yesterday),
        "daily": daily_resp["ResultsByTime"][0],
        "month_to_date": monthly_resp["ResultsByTime"][0],
        "previous_month": {
            "start": str(first_day_prev_month),
            "end": str(last_day_prev_month),
            "data": prev_month_resp["ResultsByTime"][0],
        },
    }

    print(f"\n📈 Cost explorer summary:\n{result}")
    return result
