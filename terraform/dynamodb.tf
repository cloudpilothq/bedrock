resource "aws_dynamodb_table" "carts" {
  name         = "Items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "customerId-index"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "BedrockCartsDynamoDBAccess"
  description = "Allow access to the Items table for carts service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.carts.arn,
          "${aws_dynamodb_table.carts.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  role       = module.eks.eks_managed_node_groups["bedrock_nodes"].iam_role_name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}
