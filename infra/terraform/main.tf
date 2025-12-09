provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "football_coaches_app" {
  bucket = "football-coaches-app-bucket"
  acl    = "private"

  tags = {
    Name        = "Football Coaches App Bucket"
    Environment = "Production"
  }
}

resource "aws_dynamodb_table" "users" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "role"
    type = "S"
  }

  tags = {
    Name        = "Users Table"
    Environment = "Production"
  }
}

resource "aws_lambda_function" "api" {
  function_name = "football_coaches_api"
  handler       = "app.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_exec.arn
  s3_bucket     = aws_s3_bucket.football_coaches_app.bucket
  s3_key        = "path/to/your/lambda/code.zip"

  environment {
    TABLE_NAME = aws_dynamodb_table.users.name
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_api_gateway_rest_api" "football_coaches_api" {
  name        = "Football Coaches API"
  description = "API for Football Coaches App"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.football_coaches_api.id
  parent_id   = aws_api_gateway_rest_api.football_coaches_api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.football_coaches_api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"

  integration {
    type             = "AWS_PROXY"
    integration_http_method = "POST"
    uri              = aws_lambda_function.api.invoke_arn
  }
}

output "api_endpoint" {
  value = "${aws_api_gateway_rest_api.football_coaches_api.invoke_url}/users"
}