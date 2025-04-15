import json

def handler(event, context):
    path = event.get('path', '')

    if path == '/health':
        return respond(200, {"message": "healthy"})

    if path == '/render':
        return respond(200, {"ok": False})

    return respond(404, {"message": f"Unknown path: {path}"})


def respond(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body)
    }
