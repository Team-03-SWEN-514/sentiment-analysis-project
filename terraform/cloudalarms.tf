# High Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "HighErrorRateAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "error-count"
  namespace           = "StockApp"
  period              = 60  # 60 sec
  statistic           = "Sum"
  threshold           = 10  # if more than 10 errors occur in 60 sec

  alarm_description = "Alarm when the error count exceeds 10 in 1 minute."
  actions_enabled    = true
  alarm_actions      = [aws_sns_topic.alerts.arn]
}

# Alarm for High DynamoDB Read Capacity
resource "aws_cloudwatch_metric_alarm" "high_dynamodb_read_capacity" {
  alarm_name          = "HighDynamoDBReadCapacity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = 60  # 60 sec
  statistic           = "Sum"
  threshold           = 100  # if read capacity >100 units in 60 sec

  dimensions = {
    TableName = aws_dynamodb_table.sentiment_analysis.name  # Replace with your DynamoDB table name
  }

  alarm_description = "Alarm when DynamoDB read capacity exceeds 100 units."
  actions_enabled    = true
  alarm_actions      = [aws_sns_topic.alerts.arn]  # Replace with your SNS topic ARN
}

# Alarm for High Lambda Invocation Errors
resource "aws_cloudwatch_metric_alarm" "lambda_invocation_errors" {
  alarm_name          = "LambdaInvocationErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60  # 60 sec
  statistic           = "Sum"
  threshold           = 1  # if there is at least 1 error

  dimensions = {
    FunctionName = aws_lambda_function.news_lambda.function_name
  }

  alarm_description = "Alarm when there is at least 1 error in the news_lambda function."
  actions_enabled    = true
  alarm_actions      = [aws_sns_topic.alerts.arn]  # Replace with your SNS topic ARN
}

resource "aws_sns_topic" "alerts" {
  name = "alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "lsf3956@rit.edu"
}