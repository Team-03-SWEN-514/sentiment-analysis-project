import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  # Change region if needed
table = dynamodb.Table('sentiment_results')

def add_sentiment_result(username, sentiment, saved):
    response = table.put_item(
        Item={
            'username': username,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'sentiment': sentiment,
            'saved': saved
        }
    )
    return response

response = add_sentiment_result("user123", 1, 1)
print("Item added:", response)
 