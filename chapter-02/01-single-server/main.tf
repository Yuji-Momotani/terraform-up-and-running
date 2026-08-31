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
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name        = "terraform-learning-web"
    Environment = "learning"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.server_port
  ip_protocol = "tcp"
  to_port     = var.server_port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Allow outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_launch_template" "web" {
  name_prefix = "terraform-learning-web-"

  image_id      = "ami-0f7e90d3283d2e250"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    sed -i 's/^Listen 80$/Listen ${var.server_port}/' /etc/httpd/conf/httpd.conf
    echo "Hello, World!" > /var/www/html/index.html
    systemctl enable --now httpd
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix = "terraform-learning-web-"

  min_size         = 2  # ASGが維持できる最小台数
  desired_capacity = 2  # ASGが現在維持しようとする目標台数（apply後にこの台数になる）
  max_size         = 10 # ASGが維持できる最大台数

  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "terraform-learning-ch2-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "learning"
    propagate_at_launch = true
  }

  depends_on = [
    aws_vpc_security_group_egress_rule.all,
  ]
}
