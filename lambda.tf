resource "aws_lambda_function" "function" {
  function_name    = local.name_rfc1123
  runtime          = "python3.8"
  timeout          = var.timeout
  filename         = data.archive_file.function_source_code.output_path
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  source_code_hash = data.archive_file.function_source_code.output_base64sha256
  kms_key_arn      = var.kms_key_arn

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? {
      vpc_config = {
        subnet_ids         = var.subnet_ids,
        security_group_ids = compact(concat([for sg in aws_security_group.lambda_default_sg : sg.id], var.additional_security_group_ids))
      }
    } : {}
    content {
      subnet_ids         = vpc_config.value["subnet_ids"]
      security_group_ids = vpc_config.value["security_group_ids"]
    }
  }

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? { variables = var.environment_variables } : {}
    content {
      variables = environment.value
    }
  }

  tags = merge(local.common_tags, var.extra_tags)
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_access
  ]
}

data "archive_file" "function_source_code" {
  type             = "zip"
  source_dir       = var.source_path
  output_path      = "${local.name_rfc1123}.zip"
  output_file_mode = "0644"
}

resource "aws_security_group" "lambda_default_sg" {
  for_each = length(var.subnet_ids) > 0 ? {
    default = {}
  } : {}
  name                   = local.name_rfc1123
  description            = "${var.name} Default Security Group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  tags = merge(
    {
      Name = "${var.name} Lambda"
    },
    local.common_tags,
    var.extra_tags
  )
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_rfc1123}"
  retention_in_days = 7
  kms_key_id        = var.kms_key_arn
  tags              = merge(local.common_tags, var.extra_tags)
}
