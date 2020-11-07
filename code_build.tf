# Artifact Bucket for dev,test, and prod environments
resource "aws_s3_bucket" "artifact_buckets" {
  #count         = length(var.s3_bucket_name)
  bucket        = "artifacts-aws-interview-jjain" #var.s3_bucket_name[count.index]
  acl           = "private"
  force_destroy = "true"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_role" "service_role" {
  name = "Web-Application-CodeBuild-Service-Role"

  assume_role_policy = file("iam_policies/codebuild-trust-policy.json")

}


resource "aws_iam_role_policy" "service_role_policy" {
  role = aws_iam_role.service_role.name

  policy = file("iam_policies/codebuild-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "codebuild_rp_attach" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_codebuild_project" "web_application_build" {
  name         = "web-application-web-build"
  description  = "Builds Web Application"
  service_role = aws_iam_role.service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0" # Ubuntu
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "BUILD_OUTPUT_BUCKET"
      value = aws_s3_bucket.artifact_buckets.id
    }

  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = "master"
}