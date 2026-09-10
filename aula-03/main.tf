resource "aws_iam_group" "developers" {
  name = "${local.name_prefix}-developers"
  path = "/technova/"
}

resource "aws_iam_group" "platform_eng" {
  name = "${local.name_prefix}-platform-eng"
  path = "/technova/"
}

resource "aws_iam_user" "juliana" {
  name = "${local.name_prefix}-juliana-dev"
  path = "/technova/"
  tags = merge(local.common_tags, { Purpose = "Developer" })
}

resource "aws_iam_user" "rafael" {
  name = "${local.name_prefix}-rafael-platform"
  path = "/technova/"
  tags = merge(local.common_tags, { Purpose = "Platform engineer" })
}

resource "aws_iam_user" "lucas" {
  name = "${local.name_prefix}-lucas-intern"
  path = "/technova/"
  tags = merge(local.common_tags, { Purpose = "Intern" })
}

resource "aws_iam_group_membership" "developers" {
  name = "${local.name_prefix}-developers-membership"
  group = aws_iam_group.developers.name
  users = [
    aws_iam_user.juliana.name,
    aws_iam_user.rafael.name,
    aws_iam_user.lucas.name,
  ]
}

resource "aws_iam_group_membership" "platform_eng" {
  name = "${local.name_prefix}-platform-membership"
  group = aws_iam_group.platform_eng.name
  users = [aws_iam_user.rafael.name]
}