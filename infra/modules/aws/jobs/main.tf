resource "aws_iam_role" "lambda_cost_explorer_role" {
  name               = var.lambda_cost_explorer_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "cost_explorer_iam_policy" {
  name   = "${var.lambda_cost_explorer_name}-iam-policy"
  policy = data.aws_iam_policy_document.cost_explorer_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "cost_explorer_iam_policy_attachment" {
  role       = aws_iam_role.lambda_cost_explorer_role.name
  policy_arn = aws_iam_policy.cost_explorer_iam_policy.arn
}

resource "aws_lambda_function" "cost_explorer" {
  function_name = var.lambda_cost_explorer_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_cost_explorer_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = local.lambda_cost_explorer_key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      REPORT_BUCKET    = var.jobs_state_bucket
      PROJECT_NAME     = var.project_name
      ENVIRONMENT_NAME = var.environment
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cost_explorer_group" {
  name              = "/aws/lambda/${aws_lambda_function.cost_explorer.function_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${var.lambda_cost_explorer_name}-daily-trigger"
  description         = "Triggers the Lambda function daily at 3:00 AM UTC"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "cost_explorer_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = var.lambda_cost_explorer_name
  arn       = aws_lambda_function.cost_explorer.arn
}

resource "aws_lambda_permission" "cost_explorer_allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_explorer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

resource "aws_iam_role" "lambda_log_processor_role" {
  name               = var.lambda_log_processor_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "log_processor_iam_policy" {
  name   = "${var.lambda_log_processor_name}-iam-policy"
  policy = data.aws_iam_policy_document.log_processor_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "log_processor_iam_policy_attachment" {
  role       = aws_iam_role.lambda_log_processor_role.name
  policy_arn = aws_iam_policy.log_processor_iam_policy.arn
}

resource "aws_lambda_function" "log_processor" {
  function_name = var.lambda_log_processor_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_log_processor_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = local.lambda_log_processor_key

  memory_size = 256
  timeout     = 180

  environment {
    variables = {
      REPORT_BUCKET  = var.jobs_state_bucket
      S3_LOGS_BUCKET = var.web_logs_bucket
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_processor_group" {
  name              = "/aws/lambda/${aws_lambda_function.log_processor.function_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_event_target" "log_processor_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = var.lambda_log_processor_name
  arn       = aws_lambda_function.log_processor.arn
}

resource "aws_lambda_permission" "log_processor_allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
