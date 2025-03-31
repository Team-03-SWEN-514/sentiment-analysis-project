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

resource "aws_iam_policy" "comprehend_policy" {
  name        = "lambda_comprehend_policy"
  description = "Policy for Lambda to call Comprehend"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "comprehend:BatchDetectSentiment"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_full_access" {
  name        = "dynamodb-full-access"
  description = "Allow Lambda full access to all DynamoDB tables"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_comprehend" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.comprehend_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_full" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_full_access.arn
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

# API Gateway REST API
resource "aws_api_gateway_rest_api" "market_api" {
  name        = "MarketAPI"
  description = "Gets stock related news and other info"
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  path        = "/"
}

# API Gateway resource for /db
resource "aws_api_gateway_resource" "db" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  parent_id   = aws_api_gateway_rest_api.market_api.root_resource_id
  path_part   = "db"
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

resource "aws_api_gateway_method" "add_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "update_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "PUT"
  authorization = "NONE"
}

# GET method for /db
resource "aws_api_gateway_method" "get_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.db.id
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

resource "aws_api_gateway_integration" "add_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.add_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_sentiment_result.invoke_arn
}

resource "aws_api_gateway_integration" "update_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.update_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_sentiment_result.invoke_arn
}

# Integration for /db GET
resource "aws_api_gateway_integration" "get_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.db.id
  http_method             = aws_api_gateway_method.get_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_sentiment_result.invoke_arn
}

# Permission for GET -> news_lambda
resource "aws_lambda_permission" "allow_apigw_invoke_news" {
  statement_id  = "AllowAPIGatewayInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/"
}

# Permission for POST -> add_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_add" {
  statement_id  = "AllowAPIGatewayInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/POST/"
}

# Permission for PUT -> update_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_update" {
  statement_id  = "AllowAPIGatewayInvokePUT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/PUT/"
}

# Lambda permission for API Gateway to call get_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_get_sentiment_result" {
  statement_id  = "AllowAPIGatewayInvokeGETDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/db"
}

# Deployment + Stage
resource "aws_api_gateway_deployment" "market_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_proxy,
    aws_api_gateway_integration.add_sentiment_result,
    aws_api_gateway_integration.update_sentiment_result
  ]
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  description = "Deploying all routes"
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.market_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  stage_name    = "market"
}

# output url for amplify to use
output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.market_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
  description = "Invoke URL for the deployed API Gateway"
}
