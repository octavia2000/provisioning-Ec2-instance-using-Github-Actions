provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  availability_zone = "us-east-1a"
}

variable "ec2_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "UbuntuAppServer"
}

resource "aws_security_group" "main" {
  name        = "allow_ssh_default_vpc_2"  # use a unique name
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
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
}

resource "aws_instance" "app_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t3.micro"
  key_name               = "app-ssh-key"
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = var.ec2_name
  }
}
