# modules/sns_lambda/main.tf

# SNS Topic
resource "aws_sns_topic" "user_verification" {
  name = "${var.environment}-${var.project_name}-user-verification"
  
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.project_name}-user-verification"
  })
}

# Lambda Function
resource "aws_lambda_function" "email_verification" {
  filename         = var.lambda_function_path
  function_name    = "${var.environment}-${var.project_name}-email-verification"
  role            = aws_iam_role.lambda_role.arn
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      DB_HOST          = var.db_host
      DB_NAME          = var.db_name
      DB_USER          = var.db_username
      DB_PASSWORD      = var.db_password
      SENDGRID_API_KEY = var.sendgrid_api_key
      DOMAIN_NAME      = var.domain_name
      FROM_EMAIL       = var.sender_email
      REGION          = var.aws_region
      DB_CONNECTION_STRING = "mysql+pymysql://${var.db_username}:${var.db_password}@${var.db_host}/${var.db_name}"
    }
  }


  tags = merge(var.tags, {
    Name = "${var.environment}-${var.project_name}-email-verification"
  })
}



# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Lambda IAM Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.environment}-${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:Unsubscribe"
        ]
        Resource = aws_sns_topic.user_verification.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:*"
        ]
        Resource = var.rds_arn
      }
    ]
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_verification.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2ToPublish"
        Effect = "Allow"
        Principal = {
          AWS = var.ec2_role_arn
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.user_verification.arn
      }
    ]
  })
  depends_on = [aws_sns_topic.user_verification]
}

# Lambda permission for SNS
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification.arn
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.user_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn
}