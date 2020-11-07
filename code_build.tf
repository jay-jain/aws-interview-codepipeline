
resource "aws_s3_bucket" "artifact_buckets" {
  bucket        = var.artifact_bucket_name
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


resource "aws_codebuild_project" "web_application_build" {
  name         = "web-application-web-build"
  description  = "Builds Web Application"
  service_role = aws_iam_role.web-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0" # Ubuntu
    type         = "LINUX_CONTAINER"

  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = "master"
}