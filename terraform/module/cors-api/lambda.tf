# Data source containing the lambda function and for putting its zipped version
data "archive_file" "lambda_zip" {
  source_file = "../module/cors-api/lambda.js"
  type = "zip"
  output_path = "../module/cors-api/lambda.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  filename = "../module/cors-api/lambda.zip"
  function_name = "cors-proxy-js"
  role = aws_iam_role.lambda.arn
  handler = "index.handler"

  source_code_hash = "${filebase64sha256(data.archive_file.lambda_zip.output_path)}"

  runtime = "nodejs12.x"
}

# IAM role for Lambda Function
resource "aws_iam_role" "lambda" {
  name = "iam-lambda-role"
   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
