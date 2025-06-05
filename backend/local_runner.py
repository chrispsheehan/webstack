import os
import json
from pathlib import Path
from dotenv import load_dotenv
from cost_explorer.cost_report import generate_cost_report

load_dotenv()

if __name__ == "__main__":
    project_name = os.environ.get("PROJECT_NAME")
    environment_name = os.environ.get("ENVIRONMENT_NAME")
    public_dir = os.environ.get("PUBLIC_DIR", "./frontend/public")
    output_path = os.environ.get(
        "OUTPUT_PATH",
        os.path.join(public_dir, "data", "cost-report", "data.json")
    )

    if not project_name or not environment_name:
        raise ValueError("PROJECT_NAME and ENVIRONMENT_NAME must be set as environment variables")

    report = generate_cost_report(project_name, environment_name)

    # Ensure directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)

    # Save to file
    with open(output_path, "w") as f:
        json.dump(report, f, indent=2)

    print(f"✅ Cost report saved to {output_path}")
