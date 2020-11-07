resource "aws_codedeploy_app" "web-app" {
  compute_platform = "Server"
  name             = "web-app"
}

resource "aws_iam_role" "code_deploy_role" {
  name = "Web-Server-Code-Deploy-Role"

  assume_role_policy = file("iam_policies/codedeploy-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code_deploy_role.name
}

resource "aws_codedeploy_deployment_group" "web-app-deployment-group" {
  app_name              = aws_codedeploy_app.web-app.name
  deployment_group_name = "web-app-deployment-group"
  service_role_arn      = aws_iam_role.code_deploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Dev"
    }
  }

}