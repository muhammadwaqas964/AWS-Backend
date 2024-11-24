import json
import boto3
from unittest.mock import patch
from moto import mock_dynamodb
import sys
import os

# Mock AWS credentials for moto
os.environ['AWS_ACCESS_KEY_ID'] = 'test'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'test'
os.environ['AWS_SECURITY_TOKEN'] = 'test'
os.environ['AWS_SESSION_TOKEN'] = 'test'

# Add the path of the lambda_function module to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'MyProject')))

from lambda_function import lambda_handler  # Import using the correct path

@mock_dynamodb
def test_lambda_handler():
    # Set up mock DynamoDB
    boto3.setup_default_session(region_name='us-east-1')  # Ensure the region is set correctly
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')  # Specify the region here
    table = dynamodb.create_table(
        TableName='waqasdynamodb',
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
    )
    table.put_item(Item={'id': 'visitors', 'visitorCount': 0})

    event = {}
    context = {}

    response = lambda_handler(event, context)
    body = json.loads(response['body'])

    assert response['statusCode'] == 200
    assert 'count' in body
    assert isinstance(body['count'], int)
