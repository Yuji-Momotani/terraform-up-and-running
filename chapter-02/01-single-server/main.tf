terraform {
  required_version = ">=1.15.0, <2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_security_group" "web" {
  name_prefix = "terraform-learning-web-"
  description = "Security group for the chapter 2 web server"

  tags = {
    Name        = "terraform-learning-web"
    Environment = "learning"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Allow outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0f7e90d3283d2e250"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    echo "Hello, World!" > /var/www/html/index.html
    systemctl enable --now httpd
  EOF

  user_data_replace_on_change = true

  # user_data内のdnf実行前に、外向き通信を許可しておく
  depends_on = [
    aws_vpc_security_group_egress_rule.all,
  ]

  tags = {
    Name        = "terraform-learning-ch2"
    Environment = "learning"
  }
}