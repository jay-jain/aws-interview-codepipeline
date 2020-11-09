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
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceZIP"]
      run_order        = "1"

      configuration = {
        RepositoryName = aws_codecommit_repository.repo.repository_name
        BranchName     = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildWebPage"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceZIP"]
      output_artifacts = ["BuildZIP"]
      version          = "1"


      configuration = {
        ProjectName = aws_codebuild_project.web_application_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "DeployToEC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["BuildZIP"]
      version          = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.web-app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.web-app-deployment-group.deployment_group_name
      }
    }
  }
}