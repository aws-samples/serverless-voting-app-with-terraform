provider "aws" {
  region = "us-west-2"
}

# --------------------------------------------------------- 
# Module 2 - Backend APIs
# ---------------------------------------------------------

resource "aws_dynamodb_table" "votes_table" {
  name         = "${var.app_name}-vote-result"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.app_name
  }
}

module "get-votes" {
  source = "terraform-aws-modules/lambda/aws"

  function_name   = "${var.app_name}-get-votes"
  description     = "get votes"
  handler         = "index.handler"
  runtime         = "nodejs16.x"
  memory_size     = 256
  build_in_docker = true

  source_path = "src/get-votes"

  environment_variables = {
    DDB_TABLE_NAME = aws_dynamodb_table.votes_table.id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:Scan",
      ],
      resources = [aws_dynamodb_table.votes_table.arn]
    }
  }

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.app_name
  }
}

module "post-votes" {
  source = "terraform-aws-modules/lambda/aws"

  function_name   = "${var.app_name}-post-votes"
  description     = "post votes"
  handler         = "index.handler"
  runtime         = "nodejs16.x"
  memory_size     = 256
  build_in_docker = true

  source_path = "src/post-votes"

  environment_variables = {
    DDB_TABLE_NAME = aws_dynamodb_table.votes_table.id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:ConditionCheckItem",
      ],
      resources = [aws_dynamodb_table.votes_table.arn]
    }
  }

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.app_name
  }
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.app_name}-api"
  description   = "voting api"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false

  # Routes and integrations
  integrations = {
    # "GET /votes" = {
    #   lambda_arn = module.get-votes.lambda_function_arn
    #   payload_format_version = "2.0"
    # }

    # "POST /votes" = {
    #   lambda_arn = module.post-votes.lambda_function_arn
    #   payload_format_version = "2.0"
    # }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.app_name
  }

}


# --------------------------------------------------------- 
# Module 3 - Aync Writes
# ---------------------------------------------------------



# ---------------------------------------------------------
# Module 4 - Realtime Updates
# ---------------------------------------------------------


