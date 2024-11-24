provider "aws" {
  region = "us-east-1"
}

resource "aws_acm_certificate" "muhammadwaqas_cert" {
  domain_name       = "*.muhammadwaqas.site"
  validation_method = "DNS"

  tags = {
    Name = "muhammadwaqas-cert"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "waqasdevops" {
  bucket = "waqasdevops"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.waqasdevops.bucket

  policy = jsonencode({
    Id = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Action    = "s3:GetObject"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::577638354548:distribution/E3MNJ92FZJSWLR"
          }
        }
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Resource = "arn:aws:s3:::waqasdevops/*"
        Sid      = "AllowCloudFrontServicePrincipal"
      },
    ]
    Version = "2008-10-17"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "resume_bucket_versioning" {
  bucket = aws_s3_bucket.waqasdevops.bucket

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "resume_bucket_sse" {
  bucket = aws_s3_bucket.waqasdevops.bucket

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudfront_distribution" "example_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloud Resume Challenge"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  aliases = [
    "*.muhammadwaqas.site"
  ]

  origin {
    domain_name              = aws_s3_bucket.waqasdevops.bucket_domain_name
    origin_id                = "waqasdevops"
    origin_access_control_id = "E3GH5BXGZHQ2DZ"
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.muhammadwaqas_cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "waqasdevops"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  lifecycle {
    prevent_destroy = true
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

  point_in_time_recovery {
    enabled = false
  }

  table_class = "STANDARD" # Ensure a valid table class is specified

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_lambda_function" "waqaslambda" { 
  function_name = "waqaslambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::577638354548:role/service-role/waqaslambda-role-s1v2ryix"  
  filename      = "lambda_function.zip"  # Reference the zip file created in the pipeline
  source_code_hash = filebase64sha256("lambda_function.zip")  # Dynamically calculated hash
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
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.waqasdevops.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.example_distribution.domain_name
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.muhammadwaqas_cert.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.waqasdynamodb.name
}

output "lambda_function_arn" {
  value = aws_lambda_function.waqaslambda.arn
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.waqas_api.id
}
