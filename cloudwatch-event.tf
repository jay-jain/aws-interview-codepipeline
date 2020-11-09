resource "aws_cloudwatch_event_rule" "codecommit" {
  name        = "trigger-pipeline"
  description = "Trigger Pipeline on CodeCommit change"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "arn:aws:codecommit:us-east-1:076858682202:WebApplication"
  ],
  "detail": {
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "master"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "pipeline" {
  rule      = aws_cloudwatch_event_rule.codecommit.name
  target_id = "TriggerCodePipeline"
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.codepipeline.arn
}


## Trust Policy
data "aws_iam_policy_document" "pipeline_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

## Policy to allow execution of codepipeline
data "aws_iam_policy_document" "pipeline" {
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["${aws_codepipeline.codepipeline.arn}"]
  }
}

resource "aws_iam_policy" "pipeline-policy" {
  name   = "CWEvent-Role-Codepipeline-Policy"
  policy = data.aws_iam_policy_document.pipeline.json
}

# IAM Role that has Trust Policy and policy to allow execution of codepipeline
resource "aws_iam_role" "codepipeline" {
  name               = "CWEvent-Role-Codepipeline"
  assume_role_policy = data.aws_iam_policy_document.pipeline_trust.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.pipeline-policy.arn
}