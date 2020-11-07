resource "aws_iam_role" "web-app-codepipeline-role" {
  name = "web-app-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "web-app-codepipeline-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [

      "${aws_s3_bucket.artifact_buckets.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
      "codebuild:StopBuild"
    ]
    resources = [
      "${aws_codebuild_project.web_application_build.arn}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/web-app-codepipeline-role"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:UploadArchive",
      "codecommit:Get*",
      "codecommit:BatchGet*",
      "codecommit:Describe*",
      "codecommit:BatchDescribe*",
      "codecommit:GitPull",
      "codecommit:CancelUploadArchive"
    ]
    resources = [
      "${aws_codecommit_repository.repo.arn}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*",
      "ec2:*"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "web-app-codepipeline-role-policy" {
  name   = "web-app-codepipeline-policy"
  role   = aws_iam_role.web-app-codepipeline-role.id
  policy = data.aws_iam_policy_document.web-app-codepipeline-role-policy.json
}


