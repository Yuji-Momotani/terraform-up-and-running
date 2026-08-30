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

resource "aws_instance" "example" {
  ami           = "ami-0f7e90d3283d2e250"
  instance_type = "t3.micro"

  tags = {
    Name        = "terraform-learning-ch2"
    Environment = "learning"
  }
}