resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "news_lambda" {
  function_name = "news_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  filename      = "../lambda/lambdapackage.zip" # path to zip

  source_code_hash = filebase64sha256("../lambda/lambdapackage.zip")

  layers = [
    aws_lambda_layer_version.yfinance.arn
  ]
}

resource "aws_lambda_layer_version" "yfinance" {
  layer_name          = "yfinance"
  description         = "YFinance and dependencies layer"
  compatible_runtimes = ["python3.13"]

  s3_bucket = var.layer_bucket
  s3_key    = "layers/yfinance-layer.zip"
}