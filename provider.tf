provider "aws" {
  region  = "us-east-1"
  version = "3.14.1"
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}