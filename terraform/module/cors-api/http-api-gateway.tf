# HTTP Api Gateway
# requires terraform aws programmatic user needs APIGatewayAdministrator permission
resource "aws_apigatewayv2_api" "api" {
  name          = "cors-proxy-api"
  protocol_type = "HTTP"
}

# Permission
resource "aws_lambda_permission" "apigw" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.lambda.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

