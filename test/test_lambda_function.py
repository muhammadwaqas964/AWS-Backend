import json
from unittest.mock import patch
import boto3
from moto import mock_dynamodb
import sys
import os

# Add the path of the lambda_function module to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'MyProject')))

from lambda_function import lambda_handler  # Import using the correct path

@mock_dynamodb
def test_lambda_handler():
    # Set up mock DynamoDB
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
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
