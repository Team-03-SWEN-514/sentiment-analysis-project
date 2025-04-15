data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/../lambda/lambda.zip"
}

data "archive_file" "db_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/db.py"
  output_path = "${path.module}/../lambda/db_lambda.zip"
}

resource "aws_lambda_layer_version" "yfinance" {
  layer_name          = "yfinance"
  description         = "YFinance and dependencies layer"
  compatible_runtimes = ["python3.13"]

  filename            = "${path.module}/../lambda/yfinance-layer.zip"  # local ZIP file path
  source_code_hash    = filebase64sha256("${path.module}/../lambda/yfinance-layer.zip")
}

resource "aws_lambda_function" "news_lambda" {
  function_name = "news_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [
    aws_lambda_layer_version.yfinance.arn
  ]
}

resource "aws_lambda_function" "sns_lambda" {
  function_name = "sns_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.sns_event_function"
  runtime       = "python3.13"
  filename      = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  layers = [
    aws_lambda_layer_version.yfinance.arn
  ]
}


resource "aws_lambda_function" "publish_lambda" {
  function_name = "publish_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.sns_send_data"
  runtime       = "python3.13"
  filename      = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  layers = [
    aws_lambda_layer_version.yfinance.arn
  ]
}

resource "aws_lambda_function" "add_sentiment_result" {
  function_name = "add_sentiment_result"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "db.add_sentiment_result"
  runtime       = "python3.13"
  filename      = data.archive_file.db_lambda_zip.output_path

  source_code_hash = data.archive_file.db_lambda_zip.output_base64sha256
}

resource "aws_lambda_function" "update_sentiment_result" {
  function_name = "update_sentiment_result"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "db.update_sentiment_result"
  runtime       = "python3.13"
  filename      = data.archive_file.db_lambda_zip.output_path

  source_code_hash = data.archive_file.db_lambda_zip.output_base64sha256
}

# Lambda function for /db GET
resource "aws_lambda_function" "get_sentiment_result" {
  function_name = "get_sentiment_result"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "db.get_sentiment_result"
  runtime       = "python3.13"
  filename      = data.archive_file.db_lambda_zip.output_path
  source_code_hash = data.archive_file.db_lambda_zip.output_base64sha256
}