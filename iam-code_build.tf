#
# iam roles
#
resource "aws_iam_role" "web-app-codebuild-role" {
  name = "web-app-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "web-app-codebuild-policy" {
  role = aws_iam_role.web-app-codebuild-role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
   {
        "Effect": "Allow",
        "Resource": [
            "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.web_application_build.name}",
            "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.web_application_build.name}:*"
        ],
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
    },
    {
      "Sid": "CodeCommitPolicy",
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": [
        "arn:aws:codecommit:us-east-1:${data.aws_caller_identity.current.account_id}:web-app"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:List*",
        "s3:Put*",
        "s3:Get*"
      ],
      "Resource": [
        "${aws_s3_bucket.artifact_buckets.arn}",
        "${aws_s3_bucket.artifact_buckets.arn}/*"
      ]
    }
  ]
}
POLICY

}

