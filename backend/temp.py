import json
from pathlib import Path
from dotenv import load_dotenv
from log_processor.logs_processor import logs_report

load_dotenv()

if __name__ == "__main__":
    report = logs_report()

    print(report)
