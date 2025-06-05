FROM python:3.13-slim

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir boto3 python-dotenv watchdog

# CMD ["watchmedo", "auto-restart", "--patterns=cost_report.py;local_runner.py", "--", "python", "local_runner.py"]

CMD ["watchmedo", "auto-restart", "--patterns=*.py", "--ignore-patterns=*.pyc;*/__pycache__/*;*/.git/*;*/.venv/*;*.swp;*.swo;*.DS_Store", "--recursive", "--debug-force-polling", "--", "python", "local_runner.py"]


