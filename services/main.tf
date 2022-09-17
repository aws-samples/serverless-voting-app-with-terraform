data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iot_endpoint" "current" {
  endpoint_type = "iot:Data-ATS"
}

module "voting-service" {
  source = "terraform-aws-modules/lambda/aws"

  function_name   = "voting-service"
  description     = "voting service"
  handler         = "run.sh"
  runtime         = "nodejs14.x"
  memory_size     = 256
  publish         = true
  build_in_docker = true

  source_path = {
    path     = "src/voting-service",
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

  function_name    = module.voting-service.lambda_function_name
  function_version = module.voting-service.lambda_function_version

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

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "update-service" {
  source = "terraform-aws-modules/lambda/aws"

  function_name   = "update-service"
  description     = "realtime update function"
  handler         = "index.handler"
  runtime         = "nodejs14.x"
  memory_size     = 256
  publish         = true
  build_in_docker = true

  source_path = {
    path     = "src/update-service",
    patterns = []
  }

  environment_variables = {
    IOT_ENDPOINT = data.aws_iot_endpoint.current.endpoint_address
  }

  event_source_mapping = {
    dynamodb = {
      event_source_arn  = aws_dynamodb_table.votes_table.stream_arn
      starting_position = "LATEST"
    }
  }

  allowed_triggers = {
    dynamodb = {
      principal  = "dynamodb.amazonaws.com"
      source_arn = aws_dynamodb_table.votes_table.stream_arn
    }
  }

  tracing_mode          = "Active"
  attach_tracing_policy = true

  attach_policies    = true
  number_of_policies = 1

  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
  ]

  attach_policy_statements = true
  policy_statements = {
    iotcore = {
      effect = "Allow",
      actions = [
        "iot:Publish",
      ],
      resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/votes"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "serverless_voting_app_pool"
  allow_unauthenticated_identities = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_iam_role" "unauthenticated" {
  name = "cognito_serverless_voting_app_poolUnauth_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
          "Effect": "Allow",
          "Principal": {
              "Federated": "cognito-identity.amazonaws.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
              "StringEquals": {
                  "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
              },
              "ForAnyValue:StringLike": {
                  "cognito-identity.amazonaws.com:amr": "unauthenticated"
              }
          }
        }
    ]
  })

  inline_policy {
    name = "cognito_iot_unauthenticated_allow_subscribe_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["iot:Connect"]
          Effect   = "Allow"
          Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/*"]
        },
        {
          Action   = ["iot:Receive"]
          Effect   = "Allow"
          Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/votes"]
        },
        {
          Action   = ["iot:Subscribe"]
          Effect   = "Allow"
          Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topicfilter/votes"]
        },
      ]
    })
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_iam_role" "authenticated" {
  name = "cognito_serverless_voting_app_poolAuth_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
          "Effect": "Allow",
          "Principal": {
              "Federated": "cognito-identity.amazonaws.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
              "StringEquals": {
                  "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
              },
              "ForAnyValue:StringLike": {
                  "cognito-identity.amazonaws.com:amr": "authenticated"
              }
          }
        }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "unauthenticated" = aws_iam_role.unauthenticated.arn
    "authenticated" = aws_iam_role.authenticated.arn
  }
}

output "apigw_endpoint" {
  value = module.api_gateway.apigatewayv2_api_api_endpoint
}

output "iotcore_endpoint" {
  value = data.aws_iot_endpoint.current.endpoint_address
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool.main.id
}