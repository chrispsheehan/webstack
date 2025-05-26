
resource "aws_iam_role" "lambda_cost_explorer_role" {
  name               = "${local.lambda_cost_explorer_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "cost_explorer_logs_access_policy" {
  name   = "${local.lambda_cost_explorer_name}-logs-access-policy"
  policy = data.aws_iam_policy_document.cost_explorer_logs_policy.json
}

resource "aws_iam_policy" "cost_explorer_policy" {
  name   = "${local.lambda_cost_explorer_name}-cost-explorer-policy"
  policy = data.aws_iam_policy_document.cost_explorer_policy.json
}

resource "aws_iam_policy" "cost_explorer_s3_policy" {
  name   = "${local.lambda_cost_explorer_name}-s3-access-policy"
  policy = data.aws_iam_policy_document.cost_explorer_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "cost_explorer_logs_access_policy_attachment" {
  role       = aws_iam_role.lambda_cost_explorer_role.name
  policy_arn = aws_iam_policy.cost_explorer_logs_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "cost_explorer_policy_attachment" {
  role       = aws_iam_role.lambda_cost_explorer_role.name
  policy_arn = aws_iam_policy.cost_explorer_policy.arn
}

resource "aws_iam_role_policy_attachment" "cost_explorer_s3_policy_attachment" {
  role       = aws_iam_role.lambda_cost_explorer_role.name
  policy_arn = aws_iam_policy.cost_explorer_s3_policy.arn
}

resource "aws_lambda_function" "cost_explorer" {
  function_name = local.lambda_cost_explorer_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_cost_explorer_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = local.lambda_cost_explorer_key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.state_results.bucket
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cost_explorer_group" {
  name              = "/aws/lambda/${aws_lambda_function.cost_explorer.function_name}"
  retention_in_days = 1
}

resource "aws_s3_bucket" "state_results" {
  bucket        = var.jobs_state_bucket
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.state_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.state_results.id
  policy = data.aws_iam_policy_document.state_results_access.json
}
