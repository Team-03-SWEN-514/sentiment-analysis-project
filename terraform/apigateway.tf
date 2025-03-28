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

# API Gateway REST API
resource "aws_api_gateway_rest_api" "market_api" {
  name        = "MarketAPI"
  description = "Gets stock related news and other info"
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  path        = "/"
}

# GET method at root accepting query string "ticker"
resource "aws_api_gateway_method" "get_ticker" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.ticker" = true
  }
}

# Lambda proxy integration
resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get_ticker.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.news_lambda.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/"
}

# Deployment + Stage
resource "aws_api_gateway_deployment" "market_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_proxy]
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  description = "Deploying GET /?ticker="
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.market_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  stage_name    = "market"
}