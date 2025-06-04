import os
import sys
import boto3
import json

from cost_explorer.cost_report import generate_cost_report

ce = boto3.client("ce")
s3 = boto3.client("s3")


def handler(event, context):
    try:
        # ─── ENV VARS ────────────────────────────────────────────────────────────
        bucket_name = os.environ["REPORT_BUCKET"]
        project_name = os.environ["PROJECT_NAME"]
        environment_name = os.environ["ENVIRONMENT_NAME"]

        combined = generate_cost_report(project_name, environment_name)

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
