import json
import yfinance as yf
import boto3
import os


def lambda_handler(event, context):
    if (
        "queryStringParameters" not in event
        or "ticker" not in event["queryStringParameters"]
    ):
        return {
            "isBase64Encoded": False,
            "statusCode": 404,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods": "GET,POST,PUT,OPTIONS",
            },
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
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Methods": "GET,POST,PUT,OPTIONS",
        },
        "body": json.dumps(
            {"sentiment_response": response["ResultList"], "news": all_news}
        ),
    }


sns = boto3.client("sns", region="us-east-2")
TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def sns_event_function(event, context):
    try:
        json_body = json.loads(event["body"])
        email = json_body.get("email")  # gets email from json request

        if not email:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "email is required for sign up"}),
            }

        response = sns.subscribe(  # sends subscription request to sns using user email
            TopicArn=TOPIC_ARN, Protocol="email", Endpoint=email
        )

        return {  # Response if successful, function should send a confirmation email to user
            "isBase64Encoded": False,
            "statusCode": 200,
            "body": json.dumps(
                {
                    "message": "you have subscribed to recieve notifcations. Check for a confirmation email in your inbox."
                }
            ),
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods": "GET,POST,PUT,OPTIONS",
            },
        }

    except Exception as error:
        return {
            "isBase64Encoded": False,
            "statusCode": 400,
            "body": json.dumps({"message": "An error has occurred"}),
        }
