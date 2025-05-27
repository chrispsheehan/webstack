FROM python:3.13-slim

WORKDIR /app

COPY . .

RUN pip install Flask boto3

RUN pip install -r api/requirements.txt

EXPOSE 8080

CMD ["python", "local_adaptor.py"]
