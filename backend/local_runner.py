import os
import json
from pathlib import Path
from dotenv import load_dotenv
from log_processor.logs_processor import logs_report
from cost_explorer.cost_report import generate_cost_report

load_dotenv()

if __name__ == "__main__":
    public_dir = os.environ.get("PUBLIC_DIR")
    
    if not public_dir:
        raise ValueError("PUBLIC_DIR must be set as an environment variable")

    cost_report_json = generate_cost_report()

    cost_report_output_path = os.environ.get(
        "OUTPUT_PATH",
        os.path.join(public_dir, "data", "cost-report", "data.json")
    )

    Path(cost_report_output_path).parent.mkdir(parents=True, exist_ok=True)

    with open(cost_report_output_path, "w") as f:
        json.dump(cost_report_json, f, indent=2)

    print(f"✅ Cost report saved to {cost_report_output_path}")

    logs_report_json = logs_report()

    log_processor_output_path = os.environ.get(
        "OUTPUT_PATH",
        os.path.join(public_dir, "data", "log-processor", "data.json")
    )

    Path(log_processor_output_path).parent.mkdir(parents=True, exist_ok=True)

    with open(log_processor_output_path, "w") as f:
        json.dump(logs_report_json, f, indent=2)

    print(f"✅ Log processor report saved to {log_processor_output_path}")
