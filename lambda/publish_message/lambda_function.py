import json
import boto3
import os

sns = boto3.client('sns', region="us-east-2")
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        json_body = json.loads(event['body'])
        stock_data = json_body.get('stock_data') # gets email from json request

        if not stock_data:
            return {
                'statusCode': 400,
                'body': json.dumps({'message' : 'email is required for sign up'})
            }
        
        response = sns.publish( # sends subscription request to sns using user email
            TopicArn = TOPIC_ARN,
            Message = stock_data,
            Subject="Stock Update!"
        )

    except Exception as error:
        return {
            'statusCode': 400,
            'body': json.dumps({'message' : 'An error has occurred'})
        }
        
