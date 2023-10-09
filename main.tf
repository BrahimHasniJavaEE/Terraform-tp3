provider "aws" {
    region = "us-east-1"
    access_key = "myAcessCode"
    secret_key = "mySeretKey" 
  
}

data "aws_ami" "app_ami" {
    most_recent = true
    owners = [ "amazon" ]

    filter {
      name = "name"
      values = [ "amzn2-ami-hvm*" ]
    }
  
}

resource "aws_instance" "myec2" {
    ami = data.aws_ami.app_ami.id
    instance_type = var.instancetype 
    key_name = "key"
    tags = var.aws_common_tag
    security_groups = ["${aws_security_group.allow_http_https.name}"]
  
}

resource "aws_security_group" "allow_http_https" {
  name = "devops-sg"
  description = " Allow http and https inbound traffic"

 ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"

  }
 

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_eip" "lb" {
    instance = aws_instance.myec2.id
    domain = "vpc"
  
}
