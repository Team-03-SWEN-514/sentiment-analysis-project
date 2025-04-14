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

# Permission for GET -> news_lambda
resource "aws_lambda_permission" "allow_apigw_invoke_news" {
  statement_id  = "AllowAPIGatewayInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/GET/"
}
