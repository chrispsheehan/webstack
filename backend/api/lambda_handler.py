import json

def handler(event, context):
    path = event.get('path', '/not/found')
    event_json = json.dumps(event, indent=2)

    # Default response
    response_body = {
        "message": "Path not found",
        "event": event_json
    }
    status_code = 404  # Default to 404 for unknown paths

    # Route handling
    if path == '/health':
        response_body = {"message": "Unhealthy"}
        status_code = 500
    elif path == '/hello':
        response_body = {"message": "Hello, World!"}
        status_code = 200
    elif path == '/test':
        response_body = {"message": "This is the test route"}
        status_code = 200
    elif path == '/goodbye':
        response_body = {"message": "Goodbye, see you later!"}
        status_code = 200
    else:
        response_body = {"message": f"Unknown path: {path}"}
        status_code = 404

    return {
        "statusCode": status_code,
        "body": json.dumps(response_body)
    }
