import boto3
from datetime import datetime
from decimal import Decimal
dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  
table = dynamodb.Table('sentiment_results')

def add_sentiment_result(ticker, positive, negative,neutral,mixed):
    response = table.put_item(
        Item={
            'ticker': ticker,
            'positive': Decimal(str(positive)),
            'negative': Decimal(str(negative)),
            'neutral': Decimal(str(neutral)),
            'mixed':Decimal(str(mixed)),
        }
    )
    return response
def update_sentiment_result(ticker, positive=None, negative=None, neutral=None, mixed=None):
    update_expression = []
    expression_attribute_values = {}
    if positive is not None:
        update_expression.append("positive = :p")
        expression_attribute_values[":p"] = Decimal(str(positive))
    if negative is not None:
        update_expression.append("negative = :n")
        expression_attribute_values[":n"] = Decimal(str(negative))
    if neutral is not None:
        update_expression.append("neutral = :ne")
        expression_attribute_values[":ne"] = Decimal(str(neutral))
    if mixed is not None:
        update_expression.append("mixed = :m")
        expression_attribute_values[":m"] = Decimal(str(mixed))
    if not update_expression:
        return {"error": "No fields to update"}

    update_expression = "SET " + ", ".join(update_expression)

    response = table.update_item(
        Key={'ticker': ticker},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="UPDATED_NEW"
    )
    return response
# response = add_sentiment_result("NVDA", 0.2, 0.1,0.3,0.5)
response = update_sentiment_result("NVDA",positive=0.5,mixed=0.2)

print("Item added:", response)
 