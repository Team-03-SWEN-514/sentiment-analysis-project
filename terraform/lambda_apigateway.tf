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

resource "aws_api_gateway_integration" "get_ticker" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get_ticker.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.news_lambda.invoke_arn
}


resource "aws_api_gateway_method" "add_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.add_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_sentiment_result.invoke_arn
}

resource "aws_api_gateway_method" "update_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.update_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_sentiment_result.invoke_arn
}

# API Gateway resource for /db
resource "aws_api_gateway_resource" "db" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  parent_id   = aws_api_gateway_rest_api.market_api.root_resource_id
  path_part   = "db"
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

# Integration for /db GET
resource "aws_api_gateway_integration" "get_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.db.id
  http_method             = aws_api_gateway_method.get_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_sentiment_result.invoke_arn
}

# API Gateway resource for /sns
resource "aws_api_gateway_resource" "sns" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  parent_id   = aws_api_gateway_rest_api.market_api.root_resource_id
  path_part   = "sns"
}

resource "aws_api_gateway_method" "subscribe_email" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.sns.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sns_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.sns.id
  http_method             = aws_api_gateway_method.subscribe_email.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sns_lambda.invoke_arn
}

# Permission for GET -> news_lambda
resource "aws_lambda_permission" "allow_apigw_invoke_news" {
  statement_id  = "AllowAPIGatewayInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/"
}

# Permission for POST -> sns_event_function
resource "aws_lambda_permission" "allow_apigw_invoke_sns" {
  statement_id  = "AllowAPIGatewayInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/POST/"
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
