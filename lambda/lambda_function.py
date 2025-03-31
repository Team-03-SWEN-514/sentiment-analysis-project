import json
import yfinance as yf
import boto3


def lambda_handler(event, context):
    if (
        "queryStringParameters" not in event
        or "ticker" not in event["queryStringParameters"]
    ):
        return {
            "isBase64Encoded": False,
            "statusCode": 404,
            "body": "No ticker is provided",
        }

    ticker = event["queryStringParameters"]["ticker"]
    ticker_data = yf.Ticker(ticker)

    all_news = ticker_data.get_news()
    summary_list = []
    for news in all_news:
        if "summary" in news["content"]:
            summary_list.append(news["content"]["summary"])

    comprehend = boto3.client("comprehend", region_name="us-east-2")
    response = comprehend.batch_detect_sentiment(
        TextList=summary_list, LanguageCode="en"
    )

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps(
            {"sentiment_response": response["ResultList"], "news": all_news}
        ),
    }
