resource "aws_sns_topic" "stock" {
  name = "stock-topic"
}

resource "aws_sns_topic_policy" "allow_public_subscribe" {
  arn = aws_sns_topic.stock.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "SNS:Subscribe"
        Resource = aws_sns_topic.stock.arn
        Condition = {
          StringLike = {
            "SNS:Protocol" = ["email", "application"]
          }
        }
      }
    ]
  })
}