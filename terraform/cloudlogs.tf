# resource "aws_kms_key" "log_group_key" {
#   description = "KMS key for encrypting Logs"
# }

resource "aws_cloudwatch_log_group" "stock_log_group" {
  name = "stock-log-group"
  retention_in_days = 30 # 1 month of retention
  # kms_key_id = aws_kms_key.log_group_key.arn
}

resource "aws_cloudwatch_log_stream" "example_log_stream" {
  name = "stock-log-stream"
  log_group_name = aws_cloudwatch_log_group.stock_log_group.name
}

resource "aws_cloudwatch_log_metric_filter" "error_metric" {
  name = "error-metric-filter"
  log_group_name = aws_cloudwatch_log_group.stock_log_group.name
  pattern = "ERROR"
  metric_transformation {
    name = "error-count"
    namespace = "StockApp"
    value = "1"
  }
}

resource "aws_iam_policy" "log_group_policy" {
  name        = "log-group-policy"
  description = "IAM policy for CloudWatch Logs access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.stock_log_group.arn
      }
    ]
  })
  
}