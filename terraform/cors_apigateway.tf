resource "aws_api_gateway_method" "options_root" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_root" {
  rest_api_id          = aws_api_gateway_rest_api.market_api.id
  resource_id          = data.aws_api_gateway_resource.root.id
  http_method          = aws_api_gateway_method.options_root.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_root_response" {
  depends_on  = [aws_api_gateway_integration.options_root]
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "options_root" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method" "options_db" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.db.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_db" {
  rest_api_id          = aws_api_gateway_rest_api.market_api.id
  resource_id          = aws_api_gateway_resource.db.id
  http_method          = aws_api_gateway_method.options_db.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_db_response" {
  depends_on  = [aws_api_gateway_integration.options_db]
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = aws_api_gateway_resource.db.id
  http_method = aws_api_gateway_method.options_db.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "options_db" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = aws_api_gateway_resource.db.id
  http_method = aws_api_gateway_method.options_db.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method" "options_sns" {
  rest_api_id   = aws_api_gateway_rest_api.market_api.id
  resource_id   = aws_api_gateway_resource.sns.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_sns" {
  rest_api_id          = aws_api_gateway_rest_api.market_api.id
  resource_id          = aws_api_gateway_resource.sns.id
  http_method          = aws_api_gateway_method.options_sns.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_sns_response" {
  depends_on  = [aws_api_gateway_integration.options_sns]
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = aws_api_gateway_resource.sns.id
  http_method = aws_api_gateway_method.options_sns.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "options_sns" {
  rest_api_id = aws_api_gateway_rest_api.market_api.id
  resource_id = aws_api_gateway_resource.sns.id
  http_method = aws_api_gateway_method.options_sns.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}