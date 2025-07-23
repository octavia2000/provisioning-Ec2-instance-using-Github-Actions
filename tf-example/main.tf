provider "aws" {
  region = "us-east-2"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get a default subnet (you can filter by AZ if you want)
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Security group allowing SSH
resource "aws_security_group" "main" {
  name        = "allow_ssh_default_vpc"
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

# EC2 instance in default VPC
resource "aws_instance" "app_server" {
  ami                    = "ami-053b0d53c279acc90"  # Ubuntu 22.04 LTS in us-east-2
  instance_type          = "t3.micro"
  key_name               = "app-ssh-key"  # Ensure this exists in your AWS account
  subnet_id              = data.aws_subnet_ids.default.ids[0]  # Use the first default subnet
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "UbuntuAppServer"
  }
}
