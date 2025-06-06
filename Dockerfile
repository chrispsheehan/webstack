FROM python:3.13-slim

WORKDIR /app
COPY ./backend .

RUN pip install --no-cache-dir boto3 python-dotenv watchdog

CMD ["watchmedo", "auto-restart", "--patterns=cost_report.py;local_runner.py", "--", "python", "local_runner.py"]

# watchmedo auto-restart --patterns=cost_report.py;local_runner.py -- python local_runner.py

# watchmedo auto-restart --patterns="backend/*.py" -- python backend/local_runner.py
