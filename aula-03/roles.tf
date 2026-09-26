data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "EC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_s3_permissions" {
  statement {
    sid       = "ApplicationDataReadWrite"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::technova-app-data-*", "arn:aws:s3:::technova-app-data-*/*"]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = merge(local.common_tags, { Purpose = "EC2 service role" })
}

resource "aws_iam_role_policy" "ec2_s3_permissions" {
  name   = "${local.name_prefix}-ec2-s3-permissions"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.ec2_s3_permissions.json
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
  tags = merge(local.common_tags, { Purpose = "EC2 instance profile" })
}