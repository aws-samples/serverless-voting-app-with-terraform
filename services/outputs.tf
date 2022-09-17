output "apigw_endpoint" {
  value = module.api_gateway.apigatewayv2_api_api_endpoint
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool.main.id
}

output "iotcore_endpoint" {
  value = data.aws_iot_endpoint.current.endpoint_address
}
