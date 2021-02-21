# Data source containing the lambda function and for putting its zipped version
data "archive_file" "lambda_zip" {
  source_file = "../module/cors-api/index.js"
  type = "zip"
  output_path = "../module/cors-api/index.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  filename = "../module/cors-api/index.zip"
  function_name = "cors-proxy-js"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "index.handler"
  publish = true
  source_code_hash = "${filebase64sha256(data.archive_file.lambda_zip.output_path)}"

  runtime = "nodejs12.x"
}

# IAM role for Lambda Function
resource "aws_iam_role" "lambda_execution_role" {
  description        = "Execution role for Lambda functions"
  name               = "iam-lambda-role"

  assume_role_policy = <<EOF
{
        "Version"  : "2012-10-17",
        "Statement": [
            {
                "Action"   : "sts:AssumeRole",
                "Principal": {  
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid"   : ""
            }
        ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_gateway_invoke_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
