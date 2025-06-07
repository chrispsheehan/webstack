import os
import json
from pathlib import Path
from dotenv import load_dotenv
from log_processor.logs_processor import logs_report
from cost_explorer.cost_report import generate_cost_report

load_dotenv()

if __name__ == "__main__":
    public_dir = os.environ.get("PUBLIC_DIR")
    output_path = os.environ.get(
        "OUTPUT_PATH",
        os.path.join(public_dir, "data", "cost-report", "data.json")
    )
    
    if not public_dir:
        raise ValueError("PUBLIC_DIR must be set as an environment variable")

    report = generate_cost_report()

    # Ensure directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)

    # Save to file
    with open(output_path, "w") as f:
        json.dump(report, f, indent=2)

    print(f"✅ Cost report saved to {output_path}")

    logs_report_json = logs_report()
