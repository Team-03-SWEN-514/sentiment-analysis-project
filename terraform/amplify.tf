
resource "aws_amplify_app" "stock_sentiment_app" {
	name = "stock_sentiment_app"
	repository = "https://github.com/Team-03-SWEN-514/sentiment-analysis-project"

	enable_auto_branch_creation = true
	enable_branch_auto_build = true
	enable_branch_auto_deletion = true

	access_token = "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"

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
	EOT
}

resource "aws_amplify_branch" "amplify" {
	app_id = aws_amplify_app.stock_sentiment_app.id
	branch_name = "amplify"
}

# data "aws_iam_policy" "AmplifyAdmin" {
#   	arn = "arn:aws:iam::aws:policy/AmplifyAdmin"
# }

# data "aws_iam_policy_document" "amplify_policy" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["amplify.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "amplify_service_role" {
# 	name = "amplify_service_role"
# 	path = "/system/"
# 	assume_role_policy = data.aws_iam_policy.AmplifyAdmin.arn
# 	# assume_role_policy = data.aws_iam_policy_document.amplify_policy.json
# }

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