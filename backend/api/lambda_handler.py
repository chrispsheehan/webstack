import json

def handler(event, context):
    # Check if the request path is '/hello'
    if event['rawPath'] == '/hello':
        response = {
            "statusCode": 200,
            "body": json.dumps({"message": "Hello, World!"})
        }
    else:
        # Default response for any other path
        response = {
            "statusCode": 404,
            "body": json.dumps({"message": "Not Found"})
        }
    
    return response

