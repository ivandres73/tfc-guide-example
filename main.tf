terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  #profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "main" {
  id = "vpc-106b3a6a"
}

resource "aws_security_group" "example" {
  # ... other configuration ...
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.main.id


  dynamic "ingress" {
    for_each = local.ingress
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      description = ingress.value.description
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    description      = "outgoing for everyone"
    prefix_list_ids  = []
    self             = false
    security_groups  = []
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Hello = "World"
  }
}

locals {
  ingress = [
    {
      port        = 443
      description = "port 443"
    },
    {
      port        = 80
      description = "port 80"
    }
  ]
}
