
resource "aws_amplify_app" "stock_sentiment_app" {
	name = "stock_sentiment_app"
	repository = "https://github.com/Team-03-SWEN-514/sentiment-analysis-project"

	enable_auto_branch_creation = true
	enable_branch_auto_build = true
	enable_branch_auto_deletion = true

	access_token = "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"
	platform     = "WEB_COMPUTE"

	auto_branch_creation_config {
	  	enable_auto_build = true
		enable_pull_request_preview = true
		enable_performance_mode = false
	}

	iam_service_role_arn = aws_iam_role.amplify_service_role.arn

	build_spec = <<-EOT
		version: 1
		frontend:
		phases:
			preBuild:
			commands:
				- npm ci
			build:
			commands:
				- npm run build
		artifacts:
			baseDirectory: .next
			files:
			- '**/*'
		cache:
			paths:
			- node_modules/**/*
			- .npm/**/*
			- .next/cache/**/*
	EOT

	environment_variables = {
		NEXT_PUBLIC_API_URL = "https://${aws_api_gateway_rest_api.market_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
	}
}

resource "aws_amplify_branch" "amplify" {
	app_id = aws_amplify_app.stock_sentiment_app.id
	branch_name = "amplify"
}

# Get the policy by name
data "aws_iam_policy" "amplify_admin_policy" {
  name = "AdministratorAccess-Amplify"
}

# Create the role
resource "aws_iam_role" "amplify_service_role" {
  name = "amplify_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
		{
			Action = "sts:AssumeRole"
			Effect = "Allow"
			Sid    = ""
			Principal = {
				Service = "amplify.amazonaws.com"
			}
		},
    ]
  })
}


# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_amplify" {
  role       = aws_iam_role.amplify_service_role.name
  policy_arn = data.aws_iam_policy.amplify_admin_policy.arn
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
  role       = aws_iam_role.amplify_service_role.name
  policy_arn = aws_iam_policy.amplify_ssm_full_access.arn
}
