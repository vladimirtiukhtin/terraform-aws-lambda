resource "aws_iam_role" "lambda" {
  name = substr("${join("", [for word in regexall("[a-zA-Z0-9+=,.@-_]*", var.name) : title(word)])}Lambda", 0, 64)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(local.common_tags, var.extra_tags)
}

resource "aws_iam_role_policy_attachment" "lambda_basic_access" {
  policy_arn = aws_iam_policy.lambda_basic_access.arn
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_policy" "lambda_basic_access" {
  name   = substr("${join("", [for word in regexall("[a-zA-Z0-9+=,.@-_]*", var.name) : title(word)])}LambdaBasicAccess", 0, 128)
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_basic_access.json
  tags   = merge(local.common_tags, var.extra_tags)
}

data "aws_iam_policy_document" "lambda_basic_access" {
  statement {
    sid    = "AllowLogStreamCreation"
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}:*" // Asterisk is absolutely crucial here
    ]
    actions = [
      "logs:CreateLogStream"
    ]
  }
  statement {
    sid    = "AllowPutLogEvents"
    effect = "Allow"
    resources = [
      aws_cloudwatch_log_group.lambda.arn,
      "${aws_cloudwatch_log_group.lambda.arn}:log-stream:*"
    ]
    actions = [
      "logs:PutLogEvents"
    ]
  }
  dynamic "statement" {
    for_each = length(var.subnet_ids) > 0 ? { AllowVPCNetworkInterfaceAccess = {} } : {}
    content {
      sid    = "AllowVPCNetworkInterfaceAccess"
      effect = "Allow"
      resources = [
        "*"
      ]
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses"
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_invocation" {
  name   = substr("${join("", [for word in regexall("[a-zA-Z0-9+=,.@-_]*", var.name) : title(word)])}LambdaInvocation", 0, 128)
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_invocation.json
  tags   = merge(local.common_tags, var.extra_tags)
}

data "aws_iam_policy_document" "lambda_invocation" {
  statement {
    sid    = "AllowLambdaInvocation"
    effect = "Allow"
    resources = [
      "*" // ToDo: fine tune this
    ]
    actions = [
      "lambda:InvokeFunction"
    ]
  }
}
