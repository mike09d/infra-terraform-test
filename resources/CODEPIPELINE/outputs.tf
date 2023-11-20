# OUTPUT ROLE ARN
output "CODE_BUILD_ROLE_ARN" {
  value = aws_iam_role.CodePipelineRole.arn
}

