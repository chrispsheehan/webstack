import os
import json
import boto3

ssm = boto3.client('ssm')
param_name = os.environ['API_KEY_SSM_PARAM']

response = ssm.get_parameter(Name=param_name, WithDecryption=True)
api_key = response['Parameter']['Value']


def lambda_handler(event, context):
    try:
        print("Received event:", json.dumps(event, indent=2))

        headers = event.get("headers", {}) or {}
        authorization_token = headers.get("authorization", "")

        api_key_param_name = os.environ.get("API_KEY_SSM_PARAM", "")
        api_resource = os.environ.get("API_RESOURCE", "")

        response = ssm.get_parameter(Name=api_key_param_name, WithDecryption=True)
        api_key = response['Parameter']['Value']

        print("API Gateway Resource:", api_resource)

        if authorization_token == api_key:
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

    print("Generated policy:", json.dumps(policy_document, separators=(",", ":")))

    return {
        "principalId": principal_id,
        "policyDocument": policy_document,
    }
