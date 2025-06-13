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

def extract_usd_amount(result_by_time, preferred_order=("UnblendedCost", "BlendedCost")) -> float:
    for metric in preferred_order:
        amount_str = result_by_time["Total"].get(metric, {}).get("Amount")
        if amount_str and float(amount_str) > 0:
            return float(amount_str)
    return 0.0

def generate_cost_report():
    metrics = ["UnblendedCost"]
    today = datetime.now(timezone.utc).date()
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
            }
        ]
    }

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

    current_month_total = extract_usd_amount(monthly_resp["ResultsByTime"][0])
    last_month_total = extract_usd_amount(prev_month_resp["ResultsByTime"][0])

    result = {
        "current-month-total": round(current_month_total, 2),
        "last-month-total": round(last_month_total, 2),
        "generated-at": str(today)
    }

    print(f"\n📈 Cost explorer summary:\n{result}")
    return result
