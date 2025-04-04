import os
import json

def lambda_handler(event, context):
    try:
        print("Received event:", json.dumps(event, indent=2))

        # Extract the token from headers
        headers = event.get("headers", {}) or {}
        authorization_token = headers.get("authorization", "")
        expected_token = os.environ.get("API_KEY", "")
        api_resource = os.environ.get("API_RESOURCE", "")

        print("Authorization token received:", authorization_token)
        print("Expected token:", expected_token)
        print("API Gateway Resource:", api_resource)

        if authorization_token == expected_token:
            print("Authorization successful. Generating Allow policy.")
            return generate_policy("user", "Allow", api_resource)
        else:
            print("Authorization failed. Generating Deny policy.")
            return generate_policy("user", "Deny", api_resource)

    except Exception as e:
        print("Error processing the authorization request:", str(e))
        raise Exception("Unauthorized")

def generate_policy(principal_id, effect, resource):
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "execute-api:Invoke",
                "Effect": effect,
                "Resource": [resource],
            }
        ]
    }

    print("Generated policy:", json.dumps(policy_document, indent=2))

    return {
        "principalId": principal_id,
        "policyDocument": policy_document,
    }
