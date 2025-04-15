# Deployment + Stage
resource "aws_api_gateway_deployment" "market_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_ticker,
    aws_api_gateway_integration.add_sentiment_result,
    aws_api_gateway_integration.update_sentiment_result,
    aws_api_gateway_integration.get_sentiment_result,
    aws_api_gateway_integration.sns_proxy,

    aws_api_gateway_integration.options_root,
    aws_api_gateway_method_response.options_root,
    aws_api_gateway_integration_response.options_root_response,

    aws_api_gateway_integration.options_db,
    aws_api_gateway_method_response.options_db,
    aws_api_gateway_integration_response.options_db_response,

    aws_api_gateway_integration.options_sns,
    aws_api_gateway_method_response.options_sns,
    aws_api_gateway_integration_response.options_sns_response,

    aws_api_gateway_integration.options_sns_publish,
    aws_api_gateway_method_response.options_sns_publish,
    aws_api_gateway_integration_response.options_sns_publish_response
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
  value       = "https://${aws_api_gateway_rest_api.market_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
  description = "Invoke URL for the deployed API Gateway"
}

resource "aws_api_gateway_integration_response" "cors_response_root" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.options_root]
}