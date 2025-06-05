FROM python:3.13-slim

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir boto3 python-dotenv

CMD ["python", "local_runner.py"]
