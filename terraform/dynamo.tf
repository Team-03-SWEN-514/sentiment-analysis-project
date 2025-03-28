 resource "aws_dynamodb_table" "sentiment_analysis" {
  name           = "sentiment_results"
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "username"
  range_key      = "timestamp"

  attribute {
    name = "username"
    type = "S" 
  }

  attribute {
    name = "timestamp"
    type = "N" 
  }

  attribute {
    name = "sentiment"
    type = "N"
  }

  attribute{
    name="saved"
    type="BOOL"
  }

  global_secondary_index {
    name               = "SentimentIndex"
    hash_key           = "sentiment"
    projection_type    = "ALL"
  }

  tags = {
    Name = "SentimentAnalysisTable"
  }
}