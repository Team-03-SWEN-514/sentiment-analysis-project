 resource "aws_dynamodb_table" "sentiment_analysis" {
  name           = "sentiment_results"
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "ticker"
  range_key      = "email"

  attribute {
    name = "ticker"
    type = "S" 
  }
  attribute {
  name = "email"
  type = "S"
}
  attribute {
    name = "positive"
    type = "N"
  }
    attribute {
    name = "negative"
    type = "N"
  }

  attribute {
    name = "neutral"
    type = "N"
  }

  attribute {
    name = "mixed"
    type = "N"
  }


  # attribute{
  #   name="saved"
  #   type="N"
  # }

  global_secondary_index {
    name               = "PositiveIndex"
    hash_key           = "positive"
    projection_type    = "ALL"
  }
    global_secondary_index {
    name               = "NegativeIndex"
    hash_key           = "negative"
    projection_type    = "ALL"
  }
    global_secondary_index {
    name               = "NeutralIndex"
    hash_key           = "neutral"
    projection_type    = "ALL"
  }
    global_secondary_index {
    name               = "MixedIndex"
    hash_key           = "mixed"
    projection_type    = "ALL"
  }
  # global_secondary_index {
  #   name               = "SavedIndex"
  #   hash_key           = "saved"
  #   projection_type    = "ALL"
  # }
  # global_secondary_index {
  #   name               = "TickerIndex"
  #   hash_key           = "ticker"
  #   projection_type    = "ALL"
  # }

  tags = {
    Name = "SentimentAnalysisTable"
  }
}