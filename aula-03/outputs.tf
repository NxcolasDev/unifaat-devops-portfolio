output "iam_users" {
  description = "Usuarios IAM criados pela atividade."
  value       = [for user in [aws_iam_user.juliana, aws_iam_user.rafael, aws_iam_user.lucas] : user.name]
}

output "iam_groups" {
  description = "Grupos IAM criados pela atividade."
  value       = [aws_iam_group.developers.name, aws_iam_group.platform_eng.name]
}

output "custom_policy_arns" {
  description = "ARNs das policies customizadas."
  value = {
    s3_read          = aws_iam_policy.s3_read.arn
    ec2_s3_full      = aws_iam_policy.ec2_s3_full.arn
    deny_destructive = aws_iam_policy.deny_destructive.arn
  }
}

output "ec2_role_arn" {
  description = "ARN da role assumivel pelo EC2."
  value       = aws_iam_role.ec2.arn
}

output "instance_profile_name" {
  description = "Nome do instance profile do EC2."
  value       = aws_iam_instance_profile.ec2.name
}