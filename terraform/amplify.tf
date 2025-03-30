
resource "aws_amplify_app" "stock_sentiment_app" {
	name = "stock_sentiment_app"
	repository = "https://github.com/Team-03-SWEN-514/sentiment-analysis-project"

	access_token = var.amplify_github_oauth_token

	production_branch = {
		branch_name = "amplify"
	}

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