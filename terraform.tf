provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}


/* 
Creating the S3 buckets.
*/
resource "aws_s3_bucket" "qa-firstname-lastname-stormreply-platform-challenge" {
  bucket = "qa-firstname-lastname-stormreply-platform-challenge-0708"
}

resource "aws_s3_bucket" "staging-firstname-lastname-stormreply-platform-challenge" {
  bucket = "staging-firstname-lastname-stormreply-platform-challenge-0708"
}



/*
Setting buckets acl.
*/
resource "aws_s3_bucket_acl" "s3-b-qa-acl" {
  bucket = aws_s3_bucket.qa-firstname-lastname-stormreply-platform-challenge.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "s3-b-staging-acl" {
  bucket = aws_s3_bucket.staging-firstname-lastname-stormreply-platform-challenge.id
  acl    = "private"
}


/*
Configure the buckets objects expiration policy.
*/
resource "aws_s3_bucket_lifecycle_configuration" "s3-b-qa-objects-expiration-policy" {
  bucket = aws_s3_bucket.qa-firstname-lastname-stormreply-platform-challenge.bucket

  rule {
    id = "bucket-objects-expiration-policy"

    expiration {
      days = 1
    }

    status = "Enabled"

  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-b-staging-objects-expiration-policy" {
  bucket = aws_s3_bucket.staging-firstname-lastname-stormreply-platform-challenge.bucket

  rule {
    id = "bucket-objects-expiration-policy"

    expiration {
      days = 1
    }

    status = "Enabled"

  }
}


/*
Creating the iam policy documents. Needed for the lambda function.
*/
data "aws_iam_policy_document" "lambda_assume_role_policy"{
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]    

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "lambda_s3" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }
}


/*
Creating the iam policy 
*/
resource "aws_iam_policy" "lambda_s3" {
  name        = "lambda-s3-permissions"
  description = "Contains S3 put permission for lambda"
  policy      = data.aws_iam_policy_document.lambda_s3.json
}


/*
Creating the iam role for the lambda function.
*/
resource "aws_iam_role" "lambda_role" {  
  name               = "lambda-role"  
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}


/*
Creating role policy attachment
*/
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}


/* 
Archiving the Python code in order to be uploaded to AWS lambda.
*/
data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "lambda_function.py" 
  output_path = "lambda_function.zip"
}


/*
Creating the Lambda.
*/
resource "aws_lambda_function" "test_lambda_function" {
  function_name    = "lambdaTest"
  filename         = "lambda_function.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  timeout          = 10
}


/*
Create cloudwatch rule.
*/
resource "aws_cloudwatch_event_rule" "test-lambda" {
  name                  = "run-lambda-function"
  description           = "Schedule lambda function"
  schedule_expression   = "rate(10 minutes)"
}


/*
Create cloudwatch event target.
*/
resource "aws_cloudwatch_event_target" "lambda-function-target" {
  target_id = "lambda-function-target"
  rule      = aws_cloudwatch_event_rule.test-lambda.name
  arn       = aws_lambda_function.test_lambda_function.arn
}


/*
Give permission to the target event to run the lambda function.
*/
resource "aws_lambda_permission" "allow_cloudwatch" {    
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.test-lambda.arn
}
