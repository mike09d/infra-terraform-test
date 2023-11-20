#ENDPOINT API GW
output "apigw_endpoint" { value = aws_apigatewayv2_api.apigw_http_endpoint.api_endpoint }