resource "aws_cloudwatch_log_group" "stock_log_group" {
  name = "stock-log-group"
}

resource "aws_cloudwatch_log_stream" "example_log_stream" {
  name = "stock-log-stream"
  log_group_name = aws_cloudwatch_log_group.stock_log_group.name
}