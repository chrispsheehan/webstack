import os
import json
from pathlib import Path
from dotenv import load_dotenv
from log_processor.logs_processor import logs_report
from cost_explorer.cost_report import generate_cost_report

load_dotenv()

import os
import json
from pathlib import Path
from dotenv import load_dotenv
from log_processor.logs_processor import logs_report
from cost_explorer.cost_report import generate_cost_report

load_dotenv()


def write_json_report(report_fn, default_rel_path: str, label: str) -> None:
    """Generate and write a JSON report to the appropriate output path."""
    public_dir = os.environ.get("PUBLIC_DIR")
    if not public_dir:
        raise ValueError("PUBLIC_DIR must be set as an environment variable")

    output_path = os.environ.get(
        "OUTPUT_PATH",
        os.path.join(public_dir, "data", default_rel_path, "data.json")
    )

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)

    report_data = report_fn()

    with open(output_path, "w") as f:
        json.dump(report_data, f, indent=2)

    print(f"✅ {label} report saved to {output_path}")


if __name__ == "__main__":
    write_json_report(generate_cost_report, "cost-explorer", "Cost")
    write_json_report(logs_report, "log-processor", "Log processor")
