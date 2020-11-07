resource "aws_codepipeline" "codepipeline" {
  name     = "Web-Application-Pipeline"
  role_arn = aws_iam_role.web-app-codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_buckets.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceZIP"]
      run_order        = "1"

      configuration = {
        RepositoryName = aws_codecommit_repository.repo.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = "1"
      configuration = {
        NotificationArn = aws_sns_topic.new_ami.arn
        CustomData      = "Approve the Packer AMI build! Double check that it'll work!"
      }
    }

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceZIP"]
      output_artifacts = ["BuildZIP"]
      version          = "1"
      run_order        = "2"

      configuration = {
        ProjectName = aws_codebuild_project.web_application_build.name
      }
    }
  }
}