import json
import yfinance as yf

def lambda_handler(event, context):
    if "queryStringParameters" not in event or "ticker" not in event["queryStringParameters"]:
        return {
            "isBase64Encoded": False,
            'statusCode': 404,
            'body': "No ticker is provided"
        }

    ticker = event["queryStringParameters"]["ticker"]
    tickerdata = yf.Ticker(ticker)
    return {
        "isBase64Encoded": False,
        'statusCode': 200,
        'body': json.dumps(tickerdata.get_news())
    }
