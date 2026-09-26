data "aws_iam_policy_document" "s3_read" {
  statement {
    sid       = "AllowReadTechnovaBuckets"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::technova-*", "arn:aws:s3:::technova-*/*"]
  }
}

resource "aws_iam_policy" "s3_read" {
  name        = "${local.name_prefix}-s3-read"
  description = "Leitura de objetos e listagem dos buckets TechNova."
  policy      = data.aws_iam_policy_document.s3_read.json
  tags        = merge(local.common_tags, { Purpose = "S3 read access" })
}

data "aws_iam_policy_document" "ec2_s3_full" {
  statement {
    sid       = "DescribeCompute"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeTags", "ec2:DescribeVolumes"]
    resources = ["*"]
  }

  statement {
    sid       = "ManageTaggedInstances"
    effect    = "Allow"
    actions   = ["ec2:StartInstances", "ec2:StopInstances", "ec2:RebootInstances"]
    resources = ["arn:aws:ec2:${var.aws_region}:*:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Project"
      values   = [var.project_name]
    }
  }

  statement {
    sid       = "ManageApplicationData"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::technova-*", "arn:aws:s3:::technova-*/*"]
  }
}

resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${local.name_prefix}-ec2-s3-full"
  description = "Gerencia EC2 marcado como TechNova e dados S3 da aplicacao."
  policy      = data.aws_iam_policy_document.ec2_s3_full.json
  tags        = merge(local.common_tags, { Purpose = "Platform operations" })
}

data "aws_iam_policy_document" "deny_destructive" {
  statement {
    sid    = "DenyDestructiveActions"
    effect = "Deny"
    actions = [
      "ec2:TerminateInstances",
      "s3:DeleteBucket",
      "s3:DeleteObject",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "deny_destructive" {
  name        = "${local.name_prefix}-deny-destructive"
  description = "Impede acoes destrutivas para os usuarios do grupo de desenvolvimento."
  policy      = data.aws_iam_policy_document.deny_destructive.json
  tags        = merge(local.common_tags, { Purpose = "Destructive action protection" })
}

resource "aws_iam_group_policy_attachment" "developers_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}

resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}

resource "aws_iam_group_policy_attachment" "platform_ec2_s3_full" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}