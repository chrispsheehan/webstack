FROM python:3.11-slim

WORKDIR /app

COPY api/lambda_handler.py .
COPY local_adaptor.py .

RUN pip install Flask

RUN ls -r

EXPOSE 8080

CMD ["python", "local_adapter.py"]
