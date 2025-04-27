
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

resource "aws_iam_policy" "sns_permissions" {
  name        = "lambda-sns-access"
  description = "Allow Lambda to publish and subscribe to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "amplify_ssm_full_access" {
  name        = "amplify-ssm-full-access"
  description = "Allow Amplify full access to SSM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: "ssm:*",  # <-- all SSM actions
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amplify_attach_ssm_full_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.amplify_ssm_full_access.arn
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

resource "aws_iam_role_policy_attachment" "attach_sns" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_permissions.arn
}