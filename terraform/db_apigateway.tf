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

resource "aws_api_gateway_method" "add_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.db.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.db.id
  http_method             = aws_api_gateway_method.add_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_sentiment_result.invoke_arn
}

resource "aws_api_gateway_method" "update_sentiment_result" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.db.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_sentiment_result" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.db.id
  http_method             = aws_api_gateway_method.update_sentiment_result.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_sentiment_result.invoke_arn
}


# Permission for POST -> add_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_add" {
  statement_id  = "AllowAPIGatewayInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/POST/db"
}

# Permission for PUT -> update_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_update" {
  statement_id  = "AllowAPIGatewayInvokePUT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/PUT/db"
}

# Lambda permission for API Gateway to call get_sentiment_result
resource "aws_lambda_permission" "allow_apigw_invoke_get_sentiment_result" {
  statement_id  = "AllowAPIGatewayInvokeGETDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_sentiment_result.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/db"
}