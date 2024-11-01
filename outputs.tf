output "function_name" {
  description = ""
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = ""
  value       = aws_lambda_function.function.arn
}

output "sg_id" {
  description = "Default Security Group ID"
  value       = try(aws_security_group.lambda_default_sg["default"].id, null)
}

output "role_arn" {
  description = "The ARN of the IAM Role"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "The name of the IAM Role"
  value       = aws_iam_role.lambda.name
}

output "invocation_policy_arn" {
  value = aws_iam_policy.lambda_invocation.arn
}
