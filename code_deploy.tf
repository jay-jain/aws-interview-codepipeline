resource "aws_codedeploy_app" "web-app" {
  compute_platform = "Server"
  name             = "web-app"
}

resource "aws_codedeploy_deployment_group" "web-app-deployment-group" {
  app_name              = aws_codedeploy_app.web-app.name
  deployment_group_name = "web-app-deployment-group"
  service_role_arn      = aws_iam_role.web-app-codedeploy-role.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Dev"
    }
  }

}