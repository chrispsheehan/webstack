from flask import Flask, request, jsonify
from handler import handler  # import your lambda logic

app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>', methods=['GET', 'POST'])
def lambda_handler(path):
    event = {
        "path": '/' + path,
        "httpMethod": request.method,
        "headers": dict(request.headers),
        "queryStringParameters": request.args,
        "body": request.get_json(silent=True),
    }

    result = handler(event, None)
    return jsonify(json.loads(result["body"])), result["statusCode"]

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
