# HTTP Api Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "cors-proxy-api"
  protocol_type = "HTTP"

  depends_on = [
    aws_lambda_function.lambda
  ]
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id               = aws_apigatewayv2_api.api.id
  integration_type     = "AWS_PROXY"

  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "API deployment"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.lambda),
      jsonencode(aws_apigatewayv2_route.api),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Permission
data "aws_caller_identity" "current" { }

resource "aws_lambda_permission" "apigw" {
  statement_id  = "allow_apigw_invoke"
	function_name = aws_lambda_function.lambda.function_name
  action        = "lambda:InvokeFunction"
	principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_stage.api.execution_arn}/${aws_apigatewayv2_route.api.route_key}"
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.api.invoke_url
}
