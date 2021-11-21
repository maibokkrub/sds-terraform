resource "aws_iam_policy" "s3" {
  name = "nextcloud_s3_iam_policy"
  path = "/nextcloud/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "nextcloud_iam_policy_s3"

  }
}

resource "aws_iam_user" "s3" {
  name                 = "nextcloud_s3_iam_user"
  path                 = "/nextcloud/"
  permissions_boundary = aws_iam_policy.s3.arn

  tags = {
    Name = "nextcloud_iam_user_s3"

  }
}

resource "aws_iam_user_policy_attachment" "s3" {
  user       = aws_iam_user.s3.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

resource "aws_iam_instance_profile" "app" {
  name = "nextcloud_app_instance_profile"
  role = aws_iam_role.app.name

  tags = {
    Name = "nextcloud_instance_profile_app"

  }
}

resource "aws_iam_instance_profile" "db" {
  name = "nextcloud_db_instance_profile"
  role = aws_iam_role.db.name

  tags = {
    Name = "nextcloud_instance_profile_db"

  }
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "nextcloud_app_iam_role"
  path               = "/nextcloud/"
  assume_role_policy = data.aws_iam_policy_document.ec2.json

  tags = {
    Name = "nextcloud_iam_role_app"

  }
}

resource "aws_iam_role" "db" {
  name               = "nextcloud_db_iam_role"
  path               = "/nextcloud/"
  assume_role_policy = data.aws_iam_policy_document.ec2.json

  tags = {
    Name = "nextcloud_iam_role_db"

  }
}

data "aws_iam_policy" "mng" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_mng" {
  role       = aws_iam_role.app.name
  policy_arn = data.aws_iam_policy.mng.arn
}

resource "aws_iam_role_policy_attachment" "db_mng" {
  role       = aws_iam_role.db.name
  policy_arn = data.aws_iam_policy.mng.arn
}