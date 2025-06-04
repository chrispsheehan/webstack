import os
from dotenv import load_dotenv
load_dotenv()

from cost_explorer.cost_report import generate_cost_report


if __name__ == "__main__":
    import json

    project_name = os.environ.get("PROJECT_NAME")
    environment_name = os.environ.get("ENVIRONMENT_NAME")

    if not project_name or not environment_name:
        raise ValueError("PROJECT_NAME and ENVIRONMENT_NAME must be set as environment variables")

    report = generate_cost_report(project_name, environment_name)

    print(json.dumps(report, indent=2))  # Print to stdout