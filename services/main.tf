data "aws_region" "current" {}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name   = "voting-api"
  description     = "voting api"
  handler         = "run.sh"
  runtime         = "nodejs14.x"
  memory_size     = 256
  publish         = true
  build_in_docker = true

  source_path = {
    path     = "src/voting-api",
    patterns = []
  }

  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
    READINESS_CHECK_PATH    = "/ready"
    DDB_TABLE_NAME          = aws_dynamodb_table.votes_table.id
  }

  layers = [
    "arn:aws:lambda:${data.aws_region.current.name}:753240598075:layer:LambdaAdapterLayerX86:3",
  ]

  tracing_mode          = "Active"
  attach_tracing_policy = true

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:BatchGetItem",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      resources = [aws_dynamodb_table.votes_table.arn]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

module "alias_live" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  refresh_alias = false

  name = "live"

  function_name    = module.lambda_function.lambda_function_name
  function_version = module.lambda_function.lambda_function_version

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "voting-api"
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
    "$default" = {
      lambda_arn = module.alias_live.lambda_alias_arn
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

resource "aws_dynamodb_table" "votes_table" {
  name         = "vote-result"
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
  }
}
