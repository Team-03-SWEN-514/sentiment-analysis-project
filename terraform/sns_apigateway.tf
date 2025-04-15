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

# Permission for POST -> sns_event_function
resource "aws_lambda_permission" "allow_apigw_invoke_sns" {
  statement_id  = "AllowAPIGatewayInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/POST/sns"
}

# /sns/publish
resource "aws_api_gateway_resource" "sns_publish" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  parent_id   = aws_api_gateway_resource.sns.id
  path_part   = "publish"
}

resource "aws_api_gateway_method" "publish_message" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.sns_publish.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sns_publish_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.market_api.id
  resource_id             = aws_api_gateway_resource.sns_publish.id
  http_method             = aws_api_gateway_method.publish_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sns_publish_lambda.invoke_arn
}

# Permission for POST -> publishing
resource "aws_lambda_permission" "allow_apigw_invoke_sns" {
  statement_id  = "AllowAPIGatewayInvokePOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_api.execution_arn}/*/POST/sns/publish"
}