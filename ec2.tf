resource "aws_instance" "web" {
  ami                    = "ami-0947d2ba12ee1ff75" # Latest Amazon Linux 2 distro
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-app.id]
  key_name                    = "MyKP"
  user_data              = file("bootstrap.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2-s3_profile.id
  tags = {
    Environment = "Dev"
  }
}

resource "aws_security_group" "web-app" {
  name        = "Web-App-SG"
  description = "Allows SSH, HTTP, Access"


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-App-SecurityGroup"
  }
}

output "ec2-ip" {
  value = aws_instance.web.public_ip
}

## NEED S3 Instance Profile

resource "aws_iam_instance_profile" "ec2-s3_profile" {
  name = "CodeDeploy-EC2-S3-Instance-Profile"
  role = aws_iam_role.ec2-s3-role.name
}

resource "aws_iam_role" "ec2-s3-role" {
  name = "EC2-S3-Role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "ec2-s3-policy" {
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["${aws_s3_bucket.artifact_buckets.arn}/*"]
  }
  
}

resource "aws_iam_role_policy" "ec2-s3-policy-role" {
  name   = "ec2-s3-role-policy"
  role   = aws_iam_role.ec2-s3-role.id
  policy = data.aws_iam_policy_document.ec2-s3-policy.json
}
