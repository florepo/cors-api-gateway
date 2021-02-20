# HTTP Api Gateway
# requires terraform aws programmatic user needs APIGatewayAdministrator permission
resource "aws_apigatewayv2_api" "api" {
  name          = "cors-proxy-api"
  protocol_type = "HTTP"
}
