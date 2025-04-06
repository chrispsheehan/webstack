import json

def handler(event, context):
    # Extract the path from the event
    path = event['requestContext']['path']
    
    # Set a default response
    response_body = {"message": "Path not found"}
    
    # Handle different paths based on the `path` parameter
    if path == '/dev/hello':
        response_body = {"message": "Hello, World!"}
    elif path == '/dev/test':
        response_body = {"message": "This is the test route"}
    elif path == '/dev/goodbye':
        response_body = {"message": "Goodbye, see you later!"}
    else:
        response_body = {"message": f"Unknown path: {path}"}

    # Return the response with status code 200 and the body
    response = {
        "statusCode": 200,
        "body": json.dumps(response_body)
    }

    return response
