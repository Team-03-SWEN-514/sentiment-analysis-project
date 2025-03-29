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
    type = "S" 
  }

  attribute {
    name = "sentiment"
    type = "N"
  }

  attribute{
    name="saved"
    type="N"
  }

attribute{
  name = "ticker"
  type = "S"
}
  global_secondary_index {
    name               = "SentimentIndex"
    hash_key           = "sentiment"
    projection_type    = "ALL"
  }
  global_secondary_index {
    name               = "SavedIndex"
    hash_key           = "saved"
    projection_type    = "ALL"
  }
  global_secondary_index {
    name               = "TickerIndex"
    hash_key           = "ticker"
    projection_type    = "ALL"
  }

  tags = {
    Name = "SentimentAnalysisTable"
  }
}