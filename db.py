import boto3
from datetime import datetime
from decimal import Decimal
dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  
table = dynamodb.Table('sentiment_results')

def add_sentiment_result(username, sentiment, saved,ticker):
    response = table.put_item(
        Item={
            'username': username,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'sentiment': Decimal(str(sentiment)),
            'saved': saved,
            'ticker': ticker
        }
    )
    return response

response = add_sentiment_result("user123", 0.5, 1,"NVDA")
print("Item added:", response)
 