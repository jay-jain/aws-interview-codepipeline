resource "aws_iam_role" "web-app-codedeploy-role" {
  name = "web-app-codedeploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "web-app-codedeploy-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:TerminateInstances",
      "tag:GetResources"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
    ]
    resources = [
      "${aws_s3_bucket.artifact_buckets.arn}/*",
    ]
  }
  
}

resource "aws_iam_role_policy" "web-codedeploy-role-policy" {
  name   = "codedeploy-policy"
  role   = aws_iam_role.web-app-codedeploy-role.id
  policy = data.aws_iam_policy_document.web-app-codedeploy-role-policy.json
}


