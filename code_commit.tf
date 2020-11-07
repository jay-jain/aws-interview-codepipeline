
resource "aws_codecommit_repository" "repo" {
  repository_name = "WebApplication"
  description     = "Basic web application for AWS Interview Demo"
}

output "repo_url" {
  value = aws_codecommit_repository.repo.clone_url_http
}