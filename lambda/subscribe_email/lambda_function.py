import json
import boto3
import os

sns = boto3.client('sns', region="us-east-2")
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        json_body = json.loads(event['body'])
        email = json_body.get('email') # gets email from json request

        if not email:
            return {
                'statusCode': 400,
                'body': json.dumps({'message' : 'email is required for sign up'})
            }
        
        response = sns.subscribe( # sends subscription request to sns using user email
            TopicArn = TOPIC_ARN,
            Protocol = 'email',
            Endpoint = email
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message' : "you have subscribed to recieve notifcations. Check for a confirmation email in your inbox."})
        }

    except Exception as error:
        return {
            'statusCode': 400,
            'body': json.dumps({'message' : 'An error has occurred'})
        }
        
