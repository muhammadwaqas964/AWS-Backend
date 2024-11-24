provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "waqaslambda" {
  function_name = "waqaslambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::577638354548:role/service-role/waqaslambda-role-s1v2ryix"
  filename      = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  memory_size       = 128
  timeout           = 3
  package_type      = "Zip"

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [filename, source_code_hash, handler, runtime, role, memory_size, timeout, package_type, ephemeral_storage, tracing_config]
  }
}

resource "aws_dynamodb_table" "waqasdynamodb" {
  name         = "waqasdynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, billing_mode, hash_key, attribute, point_in_time_recovery, table_class]
  }
}

resource "aws_api_gateway_rest_api" "waqas_api" {
  api_key_source = "HEADER"
  name           = "WAQAS-Api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [api_key_source, endpoint_configuration]
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.waqaslambda.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.waqasdynamodb.name
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.waqas_api.id
}

