import os
import boto3
from datetime import datetime, timedelta

ce = boto3.client("ce")


project_name = os.environ["PROJECT_NAME"]
environment_name = os.environ["ENVIRONMENT_NAME"]

if not project_name:
    raise ValueError("PROJECT_NAME must be set")
if not environment_name:
    raise ValueError("ENVIRONMENT_NAME must be set")

def generate_cost_report():
    metrics = ["BlendedCost", "UnblendedCost"]
    today = datetime.utcnow().date()
    yesterday = today - timedelta(days=1)
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
        TimePeriod={"Start": str(yesterday), "End": str(today)},
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

    return {
        "date": str(yesterday),
        "daily": daily_resp["ResultsByTime"][0],
        "month_to_date": monthly_resp["ResultsByTime"][0],
        "previous_month": {
            "start": str(first_day_prev_month),
            "end": str(last_day_prev_month),
            "data": prev_month_resp["ResultsByTime"][0],
        },
    }
