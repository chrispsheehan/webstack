from flask import Flask, jsonify, request
from mangum import Mangum

app = Flask(__name__)

# Log incoming requests
@app.before_request
def log_request_info():
    app.logger.info(f"Method: {request.method}, Path: {request.path}, Headers: {dict(request.headers)}, Query: {request.query_string.decode()}, Body: {request.data.decode() if request.data else ''}")

@app.route("/hello", methods=["GET"])
def hello():
    return jsonify({"message": "Hello from Lambda!"})

@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def catch_all(path):
    return jsonify({"message": f"Catch-all hit: {request.path}"}), 200

# Handler for AWS Lambda
handler = Mangum(app, lifespan="off")
