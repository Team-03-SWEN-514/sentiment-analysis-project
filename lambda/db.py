import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  
table = dynamodb.Table('sentiment_results')

def add_sentiment_result(event, context):
    try:
        body_data = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return {
            "isBase64Encoded": False,
            "statusCode": 400,
            "body": "Invalid JSON",
        }
    
    if "ticker" not in body_data:
        return {
            "isBase64Encoded": False,
            "statusCode": 404,
            "body": "No ticker is provided",
        }
    
    response = table.put_item(
        Item={
            'ticker': body_data["ticker"],
            'positive': Decimal(str(body_data.get("positive", 0))),
            'negative': Decimal(str(body_data.get("negative", 0))),
            'neutral': Decimal(str(body_data.get("neutral", 0))),
            'mixed':Decimal(str(body_data.get("mixed", 0))),
        }
    )
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps(
            {"response": "success"}
        ),
    }

def update_sentiment_result(event, context):
    try:
        body_data = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return {
            "isBase64Encoded": False,
            "statusCode": 400,
            "body": "Invalid JSON",
        }
    
    if "ticker" not in body_data:
        return {
            "isBase64Encoded": False,
            "statusCode": 404,
            "body": "No ticker is provided",
        }
    
    update_expression = []
    expression_attribute_values = {}
    if "positive" in body_data:
        update_expression.append("positive = :p")
        expression_attribute_values[":p"] = Decimal(str(body_data["positive"]))
    if "negative" in body_data:
        update_expression.append("negative = :n")
        expression_attribute_values[":n"] = Decimal(str(body_data["negative"]))
    if "neutral" in body_data:
        update_expression.append("neutral = :ne")
        expression_attribute_values[":ne"] = Decimal(str(body_data["neutral"]))
    if "mixed" in body_data:
        update_expression.append("mixed = :m")
        expression_attribute_values[":m"] = Decimal(str(body_data["mixed"]))
    if not update_expression:
        return {"error": "No fields to update"}

    update_expression = "SET " + ", ".join(update_expression)

    response = table.update_item(
        Key={'ticker': body_data["ticker"]},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="UPDATED_NEW"
    )
    
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps(
            {"response": "success"}
        ),
    }
# response = add_sentiment_result("NVDA", 0.2, 0.1,0.3,0.5)
# response = update_sentiment_result("NVDA",positive=0.5,mixed=0.2)

# print("Item added:", response)
 